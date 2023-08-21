#!/bin/bash

# Path to the CSV file
CSV_FILE="configs/CLI_list.csv"

# Loop over each line in the CSV file
while IFS=, read -r combined_id project_version; do
    echo "Automating project: $combined_id with version: $project_version"

    # Extract groupId and artifactId from the combined_id
    IFS=':' read -ra id_parts <<< "$combined_id"
    group_id="${id_parts[0]}"
    artifact_id="${id_parts[1]}"

    # Create a new project directory
    project_name="$artifact_id"  # Using artifactId as project name
    mkdir -p "$project_name"

    # Copy template pom.xml to project directory
    cp templates/project_template/pom.xml "$project_name/"

    # Replace placeholders in the copied pom.xml with actual values
    sed -i "s|<!-- ADD_GROUP_ID -->|$group_id|g" "$project_name/pom.xml"
    sed -i "s|<!-- ADD_ARTIFACT_ID -->|$artifact_id|g" "$project_name/pom.xml"
    sed -i "s|<!-- ADD_VERSION -->|$project_version|g" "$project_name/pom.xml"
    sed -i "s|<!-- ADD_PROJECT_NAME -->|$project_name|g" "$project_name/pom.xml"

    # Add specific dependencies
    echo "    <dependency>" >> "$project_name/pom.xml"
    echo "        <groupId>com.example</groupId>" >> "$project_name/pom.xml"
    echo "        <artifactId>example-artifact</artifactId>" >> "$project_name/pom.xml"
    echo "        <version>1.0.0</version>" >> "$project_name/pom.xml"
    echo "    </dependency>" >> "$project_name/pom.xml"

    # Navigate to the project directory
    cd "$project_name"

    # Run Ekstazi tests
    mvn ekstazi:ekstazi

    # Return to the main directory
    cd ..

done < "$CSV_FILE"

