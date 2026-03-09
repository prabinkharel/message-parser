# satellite_hex_parsing

A Flutter web application for parsing satellite hex messages.

**Live Demo:** [https://prabinkharel.github.io/message-parser/](https://prabinkharel.github.io/message-parser/)

---

## GitHub Pages Deployment

### Automatic Deployment

**Yes — pushing to `master` will automatically publish to GitHub Pages.**

The project uses a GitHub Actions workflow (`.github/workflows/deploy.yml`) that:

1. Triggers on every push to the `master` branch
2. Builds the Flutter web app with the correct base path
3. Deploys the built output to the `gh-pages` branch
4. GitHub Pages serves the app from `gh-pages`

**To publish updates:**

```bash
git add .
git commit -m "Your update message"
git push origin master
```

Check the [Actions](https://github.com/prabinkharel/message-parser/actions) tab to monitor the build and deployment status.

### Repository Structure

| Branch     | Purpose                                      |
| ---------- | -------------------------------------------- |
| `master`   | Flutter source code — edit and push here     |
| `gh-pages` | Built web output — auto-updated by workflow  |

**Important:** Do not edit `gh-pages` manually. It is overwritten on each deployment.

### Manual Deployment (Optional)

If you need to deploy without pushing to `master`:

```bash
flutter build web --base-href "/message-parser/"
git subtree push --prefix build/web origin gh-pages
```

---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
