#!/usr/bin/env python3
"""
Publication-quality plot comparing throughput across FIFO, SP-PIFO, and CT-PIFO schedulers.
Generates a single-row figure with shared legend on top, suitable for IEEE journal submission.
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl

# Set global font to Liberation Serif (metrically compatible with Times New Roman)
mpl.rcParams['font.family'] = 'serif'
mpl.rcParams['font.serif'] = ['Liberation Serif', 'DejaVu Serif']
mpl.rcParams['font.size'] = 18
mpl.rcParams['mathtext.fontset'] = 'dejavuserif'

# Data files
DATA_FILES = {
    'FIFO': '/home/palhad/p4/throughput_data_fifo.csv',
    'SP-PIFO': '/home/palhad/p4/throughput_data_sppifo.csv',
    'CT-PIFO': '/home/palhad/p4/throughput_data_ctpifo.csv',
}

# Flow label mapping
FLOW_LABELS = {
    'h5': 'Flow 1',
    'h6': 'Flow 2',
    'h7': 'Flow 3',
    'h8': 'Flow 4',
}

# Colors for consistent flow representation across subplots
FLOW_COLORS = {
    'h5': '#1f77b4',  # blue
    'h6': '#ff7f0e',  # orange
    'h7': '#2ca02c',  # green
    'h8': '#d62728',  # red
}

def load_data(filepath):
    """Load CSV data and return a DataFrame."""
    df = pd.read_csv(filepath)
    return df

def plot_scheduler_comparison(output_path='/home/palhad/p4/scheduler_comparison.png'):
    """
    Create a single-row figure with three subplots (FIFO, SP-PIFO, CT-PIFO),
    shared legend on top, and titles at the bottom of each subplot.
    """
    # Create figure with 1 row, 3 columns
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5), sharey=True)
    
    # Track handles/labels for shared legend
    handles_dict = {}
    
    for idx, (scheduler_name, filepath) in enumerate(DATA_FILES.items()):
        ax = axes[idx]
        df = load_data(filepath)
        
        # Get unique flows sorted
        flows = sorted(df['flow'].unique())
        
        for flow in flows:
            flow_data = df[df['flow'] == flow].sort_values('time_rel')
            if not flow_data.empty:
                label = FLOW_LABELS.get(flow, flow)
                color = FLOW_COLORS.get(flow, None)
                line, = ax.step(
                    flow_data['time_rel'],
                    flow_data['throughput_mbps'],
                    where='post',
                    label=label,
                    color=color,
                    linewidth=1.5
                )
                # Store handle for legend (only need once per flow)
                if flow not in handles_dict:
                    handles_dict[flow] = line
        
        # Axis labels
        ax.set_xlabel('Time (seconds)', fontsize=18)
        if idx == 0:
            ax.set_ylabel('Throughput (Mbps)', fontsize=18)
        
        # Subplot title at the bottom (using xlabel position or text)
        ax.set_title(scheduler_name, fontsize=18, pad=10)
        
        # Grid and limits
        ax.grid(True, linewidth=0.3, alpha=0.7)
        ax.set_ylim(bottom=0)
        ax.set_xlim(left=0)
        
        # Tick font size
        ax.tick_params(axis='both', labelsize=16)
    
    # Create shared legend on top
    # Order handles by flow number
    ordered_flows = ['h5', 'h6', 'h7', 'h8']
    legend_handles = [handles_dict[f] for f in ordered_flows if f in handles_dict]
    legend_labels = [FLOW_LABELS[f] for f in ordered_flows if f in handles_dict]
    
    fig.legend(
        legend_handles,
        legend_labels,
        loc='upper center',
        ncol=4,
        fontsize=18,
        frameon=True,
        bbox_to_anchor=(0.5, 1.02)
    )
    
    # Adjust layout to make room for legend on top
    plt.tight_layout(rect=[0, 0, 1, 0.92])
    
    # Save figure
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    print(f"Plot saved to {output_path}")
    
    # Also save as PDF for journal submission
    pdf_path = output_path.replace('.png', '.pdf')
    plt.savefig(pdf_path, dpi=300, bbox_inches='tight')
    print(f"PDF saved to {pdf_path}")
    
    plt.close()

if __name__ == "__main__":
    plot_scheduler_comparison()
