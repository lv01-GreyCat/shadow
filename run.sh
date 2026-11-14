set -e

output_dir="output"

##################################################

get_value() {
  awk -v key="$1" '
    index($0, "=") {
      name = substr($0, 1, index($0, "=") - 1)
      value = substr($0, index($0, "=") + 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)

      if (name == key) {
        quote = substr(value, 1, 1)
        if ((quote == "\"" || quote == sprintf("%c", 39)) &&
            substr(value, length(value), 1) == quote) {
          value = substr(value, 2, length(value) - 2)
        }
        print value
        exit
      }
    }
  ' "$2"
}

##################################################

name="$(get_value name pack.toml)"
version="$(get_value version pack.toml)"

filename="${name}-${version}.mrpack"
filepath="${output_dir}/${filename}"

if [ -e "$filepath" ]; then

	echo "Warning: ${filepath} already exists."
	echo "Replace ? [y/N]"
	read -e yesno
	if [[ "$yesno" == "yes" ]]; then
		rm -rf "${filepath}"
	else
		echo "Exiting..."
		exit 1
	fi

fi
mkdir -p "${output_dir}"

packwiz modrinth export --output "${filepath}"
