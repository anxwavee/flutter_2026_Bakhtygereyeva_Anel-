# never_overflows — Practice 5

A contacts screen with twenty cards and no `setState`. It handles light and dark mode from a single seed colour.

## Setup
```
cd ~/practices/never_overflows
flutter create .     # adds android/ios/etc., keeps the existing lib/ files
flutter run
```

## Break-it-on-purpose checks (do these, they're graded)
1. **Level 2 overflow:** in `contact_card.dart`, replace `Expanded(child: Column(...))` with just the `Column`. Hot reload, then find
   `A RenderFlex overflowed by N pixels on the right` in the console. Write N in the comment above the `Row`, then put `Expanded` back.
2. **Level 3 unbounded height:** in `contact_list.dart`, remove the `Expanded` around `ListView.separated`. You get
   `Vertical viewport was given unbounded height`. Put it back. Try `shrinkWrap: true` once, then remove it.
3. **Level 4 stack order:** in the `Stack`, move the `if (contact.unread > 0) Positioned(...)` above the `CircleAvatar`.
   Hot reload and save a screenshot as `stack_swapped.png`, then swap them back.
4. **Level 5 theme:** change `seed` in `main.dart` to `Colors.teal`, check light and dark, then change it back.
   Take `screenshot_light.png` and `screenshot_dark.png` with the phone in each mode.

## Before submitting
```
dart format .
flutter analyze      # should print: No issues found!
git add . && git commit -m "Practice 5: a screen that never overflows"
git push
```
