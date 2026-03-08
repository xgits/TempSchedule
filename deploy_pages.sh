#!/bin/bash
# Deploy GDC schedule HTML to GitHub Pages
# Usage: bash deploy_pages.sh
#
# Prerequisites:
#   1. Create a GitHub repo (e.g. gdc2026-schedule), can be private
#   2. Enable GitHub Pages: Settings -> Pages -> Source: "Deploy from a branch" -> Branch: main, / (root)
#   3. Run this script after generating schedules

set -e

REPO_URL="${GDC_PAGES_REPO:-}"
OUTPUT_DIR="d:/UCWork/GDC2/output"
DEPLOY_DIR="d:/UCWork/GDC2/.deploy"

if [ -z "$REPO_URL" ]; then
    echo "Error: Set GDC_PAGES_REPO environment variable first."
    echo "  Example: export GDC_PAGES_REPO=git@github.com:yourname/gdc2026-schedule.git"
    exit 1
fi

# Prepare deploy directory
rm -rf "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR"

# Clone or init
git clone --depth 1 "$REPO_URL" "$DEPLOY_DIR" 2>/dev/null || {
    cd "$DEPLOY_DIR"
    git init
    git remote add origin "$REPO_URL"
}

# Copy output files
cp "$OUTPUT_DIR"/schedule_*.html "$DEPLOY_DIR/" 2>/dev/null || {
    echo "Error: No schedule HTML files found in $OUTPUT_DIR"
    exit 1
}

# Generate index page with links to all days
cat > "$DEPLOY_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>GDC 2026 Team Schedule</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f0f2f5; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
.container { text-align: center; padding: 40px 20px; }
h1 { font-size: 28px; color: #1a237e; margin-bottom: 8px; }
.subtitle { color: #666; margin-bottom: 32px; font-size: 15px; }
.days { display: flex; flex-wrap: wrap; gap: 12px; justify-content: center; }
.day-link {
    display: block; padding: 20px 32px; background: white; border-radius: 12px;
    text-decoration: none; color: #1976d2; font-size: 18px; font-weight: 600;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: transform 0.2s, box-shadow 0.2s;
    min-width: 140px;
}
.day-link:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.15); }
.day-link small { display: block; font-size: 12px; color: #999; font-weight: 400; margin-top: 4px; }
</style>
</head>
<body>
<div class="container">
    <h1>GDC 2026 Team Schedule</h1>
    <div class="subtitle">LD / GW / LYF</div>
    <div class="days">
        <a class="day-link" href="schedule_Monday.html">Monday<small>Mar 9</small></a>
        <a class="day-link" href="schedule_Tuesday.html">Tuesday<small>Mar 10</small></a>
        <a class="day-link" href="schedule_Wednesday.html">Wednesday<small>Mar 11</small></a>
        <a class="day-link" href="schedule_Thursday.html">Thursday<small>Mar 12</small></a>
        <a class="day-link" href="schedule_Friday.html">Friday<small>Mar 13</small></a>
    </div>
</div>
</body>
</html>
HTMLEOF

# Commit and push
cd "$DEPLOY_DIR"
git add -A
git commit -m "Update GDC schedules $(date +%Y-%m-%d)" || echo "No changes to commit"
git push -u origin main || git push -u origin master

echo ""
echo "Deployed! Your schedule is live at:"
echo "  https://<your-username>.github.io/<repo-name>/"
echo ""

# Cleanup
rm -rf "$DEPLOY_DIR"
