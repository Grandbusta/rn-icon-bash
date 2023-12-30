#Bash Script to setup react-native-vector-icons for IOS and Android

# Usage:
# Install react-native-vector-icons in your app and run the script below in your app root directry

# Script:
# bash <(curl -s https://gist.githubusercontent.com/Grandbusta/3bac9985a1c8a8580f5d271e13a88705/raw/cbe4676e07c453a42e5c26de9aae490ce97ae2db/rnicons.sh)

PACKAGE_JSON_PATH="package.json"
PACKAGE_NAME="react-native-vector-icons"
MODULE_DIRECTORY="node_modules/react-native-vector-icons"
IOS_FONTS_PATH="ios/fonts"
ANDROID_BUILD_GRADLE_PATH="android/app/build.gradle"
ANDROID_MODULE_TO_APPLY="../../node_modules/react-native-vector-icons/fonts.gradle"
ANDROID_MODULE_TO_APPLY_TEXT='"../../node_modules/react-native-vector-icons/fonts.gradle"'


setupAndroid(){
    content=$(<$ANDROID_BUILD_GRADLE_PATH)
    if [[ $content == *"$ANDROID_MODULE_TO_APPLY"* ]]; then
        echo "Already applied to $ANDROID_BUILD_GRADLE_PATH"
    else
        echo apply from: $ANDROID_MODULE_TO_APPLY_TEXT >> $ANDROID_BUILD_GRADLE_PATH
        echo "Applied to $ANDROID_BUILD_GRADLE_PATH"
        exit 1
    fi
}

writeToPlist(){
    line_to_insert=$1
    file=$2
    before_data=$(awk -v start=1 -v end="$line_to_insert" 'NR >= start && NR <= end' $file)
    data='
    <key>UIAppFonts</key>
	<array>
		<string>fonts/FontAwesome.ttf</string>
		<string>fonts/AntDesign.ttf</string>
		<string>fonts/Entypo.ttf</string>
		<string>fonts/EvilIcons.ttf</string>
		<string>fonts/Feather.ttf</string>
		<string>fonts/FontAwesome5_Brands.ttf</string>
		<string>fonts/FontAwesome5_Regular.ttf</string>
		<string>fonts/FontAwesome5_Solid.ttf</string>
		<string>fonts/Fontisto.ttf</string>
		<string>fonts/Foundation.ttf</string>
		<string>fonts/Ionicons.ttf</string>
		<string>fonts/MaterialCommunityIcons.ttf</string>
		<string>fonts/MaterialIcons.ttf</string>
		<string>fonts/Octicons.ttf</string>
		<string>fonts/SimpleLineIcons.ttf</string>
		<string>fonts/Zocial.ttf</string>
	</array>'
    after_data=$(awk -v start="$(($line_to_insert+1))" 'NR >= start' $file)
cat >$file <<EOL
$before_data
$data
$after_data
EOL
}

setupIOS(){
    mkdir -p $IOS_FONTS_PATH;
    cp -R "$MODULE_DIRECTORY/Fonts/." "$IOS_FONTS_PATH"
    workspace_path=$(ls -d ios/*xcworkspace)
    IFS='/' read -ra ADDR <<< "$workspace_path"
    arr_in=(${ADDR[1]//./ })
    project_name=${arr_in[0]}
    plist_path="ios/$project_name/Info.plist"
    plist_line_num="$(awk 'match($0,"</plist>"){ print NR;exit }' $plist_path)"
    ui_app_fonts_line="$(awk 'match($0,"<key>UIAppFonts</key>"){ print NR;exit }' $plist_path)"
    line_to_insert=$(($plist_line_num-2))

    # Check if <key>UIAppFonts</key> has already been added to Info.plist
    if [ -z "${ui_app_fonts_line}" ];then
        writeToPlist $line_to_insert "ios/$project_name/Info.plist"
    else
        echo "<key>UIAppFonts</key> already exist in $plist_path"
    fi
}

checkDirectory(){
    if [ -d "$MODULE_DIRECTORY" ];then
        echo "$PACKAGE_NAME already installed."
        setupIOS
        setupAndroid
    else
        echo "$PACKAGE_NAME not installed."
    fi
}

checkPackage(){
    content=$(<$PACKAGE_JSON_PATH)
    if [[ $content == *"$PACKAGE_NAME"* ]]; then
        echo "$PACKAGE_NAME found."
        checkDirectory
    else
        echo "$PACKAGE_NAME not found."
        exit 1
    fi
}

if test -f $PACKAGE_JSON_PATH;
then
    echo "package.json found."
    checkPackage
else
    echo "package.json not found."
    exit 1
fi

