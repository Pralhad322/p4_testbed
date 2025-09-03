#!/usr/bin/env python3

import json
import csv
import os

def convert_csv_to_json(csv_file, json_file):
    """Convert the flow mapping CSV file to JSON format."""
    try:
        # Read the CSV file
        data = []
        with open(csv_file, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # Convert flow_id and flow_size to integers
                if 'flow_id' in row:
                    try:
                        row['flow_id'] = int(row['flow_id'])
                    except ValueError:
                        pass
                if 'flow_size' in row:
                    try:
                        row['flow_size'] = int(row['flow_size'])
                    except ValueError:
                        pass
                data.append(row)
        
        # Write to JSON
        with open(json_file, 'w') as f:
            json.dump(data, f, indent=4)
        
        print(f"Successfully converted {csv_file} to {json_file}")
        return True
    except Exception as e:
        print(f"Error converting CSV to JSON: {e}")
        return False

if __name__ == "__main__":
    csv_file = 'flow_mapping_info.csv'
    json_file = 'flow_mapping_info.json'
    convert_csv_to_json(csv_file, json_file)
