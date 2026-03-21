# Chrome Remote Debugging shortcut

```bash
# Install Chrome
brew install --cask google-chrome

# Create shortcut
mkdir -p "/Applications/Chrome Debugger.app/Contents/MacOS"

tee "/Applications/Chrome Debugger.app/Contents/MacOS/Chrome Debugger" << EOF
#!/usr/bin/env bash
exec arch -arm64 "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222
EOF

chmod +x "/Applications/Chrome Debugger.app/Contents/MacOS/Chrome Debugger"

# Set icon
mkdir -p "/Applications/Chrome Debugger.app/Contents/Resources"

cp ${pwd}/ChromeDebugger.icns \
   "/Applications/Chrome Debugger.app/Contents/Resources/app.icns"

# Refresh icon cache
touch "/Applications/Chrome Debugger.app"
killall Dock

# Open Chrome Debugger
```
