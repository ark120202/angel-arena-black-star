@echo off
node start_tools.js
node node_modules/gulp/bin/gulp.js watch
if NOT ["%errorlevel%"]==["0"] pause
