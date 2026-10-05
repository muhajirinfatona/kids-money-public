#!/usr/bin/env bash
set -euo pipefail

: "${ANDROID_KEYSTORE_BASE64:?ANDROID_KEYSTORE_BASE64 belum diatur}"
: "${KEYSTORE_PASSWORD:?KEYSTORE_PASSWORD belum diatur}"
: "${KEY_ALIAS:?KEY_ALIAS belum diatur}"
: "${KEY_PASSWORD:?KEY_PASSWORD belum diatur}"

printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64 --decode > android/upload-keystore.jks
cat > android/key.properties <<EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=upload-keystore.jks
EOF

if [[ -f android/app/build.gradle.kts ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path('android/app/build.gradle.kts')
s = p.read_text()
header = '''\nimport java.util.Properties\n\nval keystoreProperties = Properties()\nval keystorePropertiesFile = rootProject.file("key.properties")\nif (keystorePropertiesFile.exists()) {\n    keystoreProperties.load(keystorePropertiesFile.inputStream())\n}\n'''
if 'keystorePropertiesFile' not in s:
    s = header + s
if 'create("release")' not in s:
    s = s.replace('    buildTypes {', '''    signingConfigs {\n        create("release") {\n            keyAlias = keystoreProperties["keyAlias"] as String\n            keyPassword = keystoreProperties["keyPassword"] as String\n            storeFile = file(keystoreProperties["storeFile"] as String)\n            storePassword = keystoreProperties["storePassword"] as String\n        }\n    }\n\n    buildTypes {''')
s = s.replace('        release {', '        getByName("release") {')
s = s.replace('            signingConfig = signingConfigs.getByName("debug")', '            signingConfig = signingConfigs.getByName("release")')
p.write_text(s)
PY
elif [[ -f android/app/build.gradle ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path('android/app/build.gradle')
s = p.read_text()
header = '''\nimport java.util.Properties\n\ndef keystorePropertiesFile = rootProject.file("key.properties")\ndef keystoreProperties = new Properties()\nif (keystorePropertiesFile.exists()) {\n    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n}\n'''
if 'keystorePropertiesFile' not in s:
    s = header + s
if 'signingConfigs {' not in s:
    s = s.replace('    buildTypes {', '''    signingConfigs {\n        release {\n            keyAlias keystoreProperties['keyAlias']\n            keyPassword keystoreProperties['keyPassword']\n            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n            storePassword keystoreProperties['storePassword']\n        }\n    }\n\n    buildTypes {''')
s = s.replace('            signingConfig signingConfigs.debug', '            signingConfig signingConfigs.release')
p.write_text(s)
PY
else
  echo 'Format Gradle Android tidak dikenali' >&2
  exit 1
fi

chmod 600 android/upload-keystore.jks android/key.properties
