# Recursively clones  or fetches "submodules" from repo.txt into extern/
while read -r url; do
    [ -z "$url" ] && continue
    name=$(basename "$url" .git)
    path="extern/$name"

    if [ -d "$path/.git" ]; then
        echo "Fetching $name..."
        (cd "$path" && git fetch)
    else
        echo "Cloning $url -> $path"
        git clone "$url" "$path"
    fi

    if [ -f "$path/update.sh" ]; then
        (cd "$path" && bash update.sh)
    fi
done < repos.txt
