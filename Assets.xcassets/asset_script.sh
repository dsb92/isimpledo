#!/bin/sh

files=`find . -name "*.jpeg"`

for i in ${files[@]}; do
    SOURCE_FILE=${i}
    DESTINATION_FILE=$SOURCE_FILE
    sips \
    --matchTo '/System/Library/ColorSync/Profiles/sRGB Profile.icc' \
    "$SOURCE_FILE" \
    --out "$DESTINATION_FILE"
done

exit 0