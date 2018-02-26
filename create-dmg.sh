#!/bin/sh

sudo sh ./clean.sh

VERSION=$(cat lib/version.py \
  | grep ELECTRUM_VERSION \
  | sed "s/[',]//g" \
  | tr -d '[[:space:]]')
VERSION=${VERSION//ELECTRUM_VERSION=/}

echo "Creating package $VERSION"

echo "brew install"
brew bundle

echo "pip install"
pip3 install -r requirements.txt

echo "Building icons"
pyrcc5 icons.qrc -o gui/qt/icons_rc.py

echo "Compiling the protobuf description file"
protoc --proto_path=lib/ --python_out=lib/ lib/paymentrequest.proto

echo "Compiling translations"
./contrib/make_locale

echo "Creating package $VERSION"
sudo python3 setup.py sdist

echo "Creating python app using py2app"
sudo ARCHFLAGS="-arch i386 -arch x86_64" sudo python3 setup-release.py py2app --includes sip

echo "Creating dist/Electrum.app and .dmg"
sudo hdiutil create -fs HFS+ -volname "Electrum BTCP - Installer" -srcfolder "dist/Electrum BTCP.app" dist/electrum-$VERSION-macosx.dmg

echo "Done!"
