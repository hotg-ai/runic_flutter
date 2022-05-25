flutter build web --web-renderer html
cp -rf ../build/web/* public/
firebase deploy
