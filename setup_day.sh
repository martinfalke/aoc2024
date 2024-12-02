#!/bin/bash -eu
if [[ -z $1 || ! $1 =~ ^[0-9]+$ || (($1 > 25))]]; then
  echo "Usage: $0 <integer=[1-25]>"
  exit 1
fi

DAY=$(printf "%02d" "$1")

# Determine the base directory of the repository
if [[ -f "./lib/dayX.ex" ]]; then
  repo_dir="."
elif [[ -f "../dayX.ex" ]]; then
  repo_dir=".."
elif [[ -f "../lib/dayX.ex" ]]; then
  repo_dir=".."
else
  echo "Error: file dayX.ex not found in current directory nor two levels above."
  exit 1
fi

source_file="$repo_dir/lib/dayX.exs"
dest_dir="$repo_dir/lib/days"
dest_file="$dest_dir/day$DAY.ex"
mkdir -p "$dest_dir"

cp "$source_file" "$dest_file"
sed -i "1s/X/$1/" "$dest_file"
sed -i "3s/X/$1/" "$dest_file"
mv -v "$repo_dir/input" "$repo_dir/lib/inputs/day$DAY.txt"

echo "Day $DAY set up successfully at: $dest_file"
