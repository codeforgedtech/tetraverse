# Tetraverse

A modern twist on the classic Tetris game, built with **Flutter** and **Flame**. Tetraverse brings beautiful visuals, glowing effects, audio feedback, and polished UI to an arcade favorite.

---

## 🚀 Features

- 🎮 Smooth touch and keyboard controls
- 🔊 Sound effects when blocks land or lines clear
- ✨ Blinking effect before line clears
- 🌈 Gradient splash screen with intro sound
- 📊 Score, level and next piece panel with glassmorphism
- 📦 Built using Flame Engine and Flame Audio

---

## 🖥️ Screenshots

> Add screenshots here if available  
> (e.g. `assets/screenshots/screenshot1.png`)

---

## 📁 Folder Structure

```
/game
│
├── CodeCraftmanSplash.dart # Animated splash screen with sound
├── game_board.dart # Tetris board rendering and logic
├── game_screen.dart # Main game screen
├── gravity.dart # Falling logic and tick control
├── input_controller.dart # Keyboard/touch input
├── level_text.dart # Displays the current level
├── next_block_display.dart # Shows upcoming tetromino
├── score_text.dart # Displays current score
├── SplashScreen.dart # Transitions to main game
├── stats_panel.dart # UI panel with blur effect
├── tetraverse_game.dart # Main Flame Game class
├── tetromino.dart # Tetromino logic (rotation, shape, etc.)
└── main.dart # Entry point
```

---

## 🔧 Getting Started

```bash
flutter pub get
flutter run
```

To regenerate app icons (after changing the icon image):

```bash
flutter pub run flutter_launcher_icons:main
```

---

## 📦 Dependencies

- [`flame`](https://pub.dev/packages/flame)
- [`flame_audio`](https://pub.dev/packages/flame_audio)
- [`audioplayers`](https://pub.dev/packages/audioplayers)
- [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons)

---

## 📱 App Icon & Name

- App name: `Tetraverse`
- Add icon in `assets/icon/app_icon.png`
- Configured via `flutter_launcher_icons` in `pubspec.yaml`

---

## 👨‍💻 Author

Created with ❤️ by [CodeCraftsMan]

---

## 📜 License

This project is licensed under the MIT License.

