#!/bin/bash -eu
last_aoc_day=25
if [[ -z $1 || ! $1 =~ ^[0-9]+$ || (${1} -gt ${last_aoc_day}) ]]; then
  echo "Usage: $0 <integer=[1-25]>"
  exit 1
fi

DAY=$(printf "%02d" "$1")
template_filename="dayX.exs"

# Determine the base directory of the repository
if [[ -f "./lib/$template_filename" ]]; then
  repo_dir="."
elif [[ -f "../$template_filename" ]]; then
  repo_dir=".."
elif [[ -f "../lib/$template_filename" ]]; then
  repo_dir=".."
else
  echo "Error: file $template_filename not found in current directory nor two levels above."
  exit 1
fi

source_file="$repo_dir/lib/$template_filename"
dest_dir="$repo_dir/lib/days"
dest_file="$dest_dir/day$DAY.ex"
mkdir -p "$dest_dir"

cp "$source_file" "$dest_file"
sed -i "1s/X/$1/" "$dest_file"
sed -i "3s/X/$1/" "$dest_file"
mv -v "$repo_dir/input" "$repo_dir/lib/inputs/day$DAY.txt"
rm -v "$repo_dir/input:Zone.Identifier"

echo "Day $DAY set up successfully at: $dest_file"
