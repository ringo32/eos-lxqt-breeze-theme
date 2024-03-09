# LXQt theme builder

# For each *.colors file, this script creates theme builds in subdirectories
# based on the color scheme defined in that file:
#   In each build, for each src/common/*.qss.in file, this script produces a
#   rendered *.qss where each occurence of a variable read from the color
#   scheme file in the format <variable>:<content> is replaced by the content.

# build directory
THEME_BASEDIR="themes"
# theme name prefix
THEME_BASENAME="Breeze"

# create the build directory if it doesn't exist
mkdir -p "$THEME_BASEDIR"

for colorfile in *".colors"; do
    # assemble the full theme name
    THEMENAME="$THEME_BASEDIR/${colorfile/.colors/} $THEME_BASENAME"
    mkdir -p "$THEMENAME"

    # build .qss files
    for name in "src/common/"*".qss.in"; do
        OUTNAME="${name/src\/common\//}"  # cut the "src/common/" from path
        OUTNAME="${OUTNAME/.qss.in/.qss}"  # cut the ".in"
        echo -e "\n$OUTNAME -> $THEMENAME/"
        cp "$name" "$THEMENAME/$OUTNAME"
        # the ` || [[ -n "$var" ]]` allows files with no newline at the end
        while IFS= read -r var || [[ -n "$var" ]]; do
            if [[ $var = \#* ]] ; then  # ignore lines starting with '#'
                : # noop
            else
                VARNAME=$(echo "$var" | cut -d':' -f 1)
                VARCONT=$(echo "$var" | cut -d':' -f 2)
                echo "$VARNAME -> $VARCONT"
                sed -i "s/$VARNAME/$VARCONT/g" "$THEMENAME/$OUTNAME"
            fi
        done <"$colorfile"
    done

    # the "#!SCHEME:<name>" line in the .colors file determines color-specific
    # files/folders to copy from src/<name>/
    BASE_SCHEME="$(grep "#\!SCHEME:" $colorfile | cut -d':' -f2)"

    # copy common directories
    for dir in $(find src/common/* -type d); do
        DIRNAME=${dir/src\/common\//}
        echo "$DIRNAME -> $THEMENAME/$DIRNAME"
        cp -r src/common/$DIRNAME "$THEMENAME/"
    done
    # copy scheme-specific directories
    for dir in $(find src/$BASE_SCHEME/* -type d); do
        DIRNAME=${dir/src\/$BASE_SCHEME\//}
        echo "$DIRNAME -> $THEMENAME/$DIRNAME"
        cp -r src/$BASE_SCHEME/$DIRNAME "$THEMENAME/"
    done

    # copy common files
    echo "*.png -> $THEMENAME/"
    cp src/common/*.png "$THEMENAME/"
    echo "*.cfg -> $THEMENAME/"
    cp src/common/*.cfg "$THEMENAME/"
    echo "*.svg -> $THEMENAME/"
    cp src/common/*.svg "$THEMENAME/"

    # copy scheme-specific files
    echo "*.png -> $THEMENAME/"
    cp src/$BASE_SCHEME/*.png "$THEMENAME/"
    echo "*.cfg -> $THEMENAME/"
    cp src/$BASE_SCHEME/*.cfg "$THEMENAME/"
    echo "*.svg -> $THEMENAME/"
    cp src/$BASE_SCHEME/*.svg "$THEMENAME/"
done

exit 0
