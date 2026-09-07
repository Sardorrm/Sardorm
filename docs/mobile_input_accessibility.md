# Mobile Input & Accessibility Contract

## Scope

Hour 8 covers answer entry and mobile interaction robustness across text, numeric, choice, and true/false puzzles.

## Acceptance criteria

- All supported answer types resolve to a deterministic input mode.
- Text and numeric inputs provide a minimum 64dp-equivalent vertical target in the gameplay UI.
- Choice/true-false buttons remain comfortably tappable and are not reduced below the shared 58px minimum.
- Numeric answers request a numeric Android keyboard.
- Enter/submit and button submission use the same validation path.
- Invalid/unknown answer types fall back safely to text input.
- Core interaction remains offline.
- Automated contract tests cover input modes and minimum touch sizing.

## Device-only gate

Real Android touch, keyboard behavior, and small-screen visual spacing still require physical-device verification. This is not marked as passed by repository inspection.
