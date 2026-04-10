# 🧩 Premium Component Usage Guide

## Components Overview

### 1. **Button** - Interactive Button Element

```tsx
import { Button } from '@/components';

// Primary button (default for calls-to-action)
<Button>Click Me</Button>

// Variants
<Button variant="primary">Primary</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="danger">Delete</Button>

// Sizes
<Button size="xs">Extra Small</Button>
<Button size="sm">Small</Button>
<Button size="md">Medium (default)</Button>
<Button size="lg">Large</Button>

// States
<Button disabled>Disabled</Button>
<Button isLoading>Loading...</Button>

// With icons
import { Heart } from 'lucide-react';
<Button variant="secondary" size="md">
  <Heart className="h-4 w-4" />
  <span>Add to Favorites</span>
</Button>
```

**Use cases:**
- Primary calls-to-action (submit, login)
- Secondary interactions (cancel, back)
- Dangerous actions (delete, logout)
- Loading states for async operations

---

### 2. **Surface** - Elevated Container Component

```tsx
import { Surface } from '@/components';

// Default raised surface
<Surface>Content here</Surface>

// Elevation levels
<Surface elevation="flat">Flat (no shadow)</Surface>
<Surface elevation="raised">Raised (default card style)</Surface>
<Surface elevation="elevated">Elevated (more shadow)</Surface>
<Surface elevation="floating">Floating (floating UI effect)</Surface>

// Background styles
<Surface background="dark">Dark background</Surface>
<Surface background="darker">Very dark background</Surface>
<Surface background="gradient">Gradient card background</Surface>
<Surface background="transparent">Transparent with blur</Surface>

// Border radius
<Surface rounded="sm">Subtle rounded</Surface>
<Surface rounded="md">Medium rounded</Surface>
<Surface rounded="lg">Large rounded (default)</Surface>
<Surface rounded="xl">Extra large</Surface>
<Surface rounded="3xl">Huge rounded</Surface>

// Padding
<Surface padding="xs">Compact</Surface>
<Surface padding="sm">Small</Surface>
<Surface padding="md">Medium (default)</Surface>
<Surface padding="lg">Large</Surface>
<Surface padding="xl">Extra large</Surface>

// Border control
<Surface border={true}>With border</Surface>
<Surface border={false}>No border</Surface>

// Combining properties
<Surface
  elevation="elevated"
  background="gradient"
  rounded="2xl"
  padding="lg"
  border={true}
>
  Creating a premium card
</Surface>
```

**Use cases:**
- Card containers
- Section backgrounds
- Modal dialogs
- Floating panels
- Elevated content areas

---

### 3. **Badge** - Status/Stat Indicator

```tsx
import { Badge } from '@/components';

// Variants for different meanings
<Badge variant="default">Default</Badge>
<Badge variant="success">✓ Success</Badge>
<Badge variant="warning">⚠ Warning</Badge>
<Badge variant="danger">✗ Error</Badge>
<Badge variant="info">ℹ Information</Badge>

// Sizes
<Badge size="sm">Small</Badge>
<Badge size="md">Medium (default)</Badge>
<Badge size="lg">Large</Badge>

// Practical examples
<Badge variant="success" size="sm">12 plays</Badge>
<Badge variant="default" size="md">Featured</Badge>
<Badge variant="warning" size="lg">Processing...</Badge>

// With icons
import { Music } from 'lucide-react';
<Badge variant="default">
  <Music className="h-4 w-4 mr-1" />
  100 tracks
</Badge>
```

**Use cases:**
- Play counts
- Track status badges
- Analytics indicators
- Status labels
- Tags and categories

---

### 4. **Label** - Semantic Typography Component

```tsx
import { Label } from '@/components';

// Variants for different text hierarchy
<Label variant="heading">Main Heading</Label>
<Label variant="subheading">Sub Heading</Label>
<Label variant="body">Body text</Label>
<Label variant="caption">Small caption text</Label>
<Label variant="label">Form label text</Label>

// Weight control
<Label weight="light">Light text</Label>
<Label weight="normal">Normal text</Label>
<Label weight="medium">Medium text</Label>
<Label weight="semibold">Semi-bold text</Label>
<Label weight="bold">Bold text</Label>

// Color semantic meaning
<Label color="primary">Important text (white)</Label>
<Label color="secondary">Secondary text (lighter)</Label>
<Label color="muted">Muted text (gray)</Label>
<Label color="success">Success message (green)</Label>
<Label color="warning">Warning message (amber)</Label>
<Label color="danger">Error message (red)</Label>

// Combinations
<Label variant="heading" weight="bold" color="primary">
  Main Title
</Label>

<Label variant="body" weight="normal" color="secondary">
  This is supporting text with secondary color
</Label>

// Practical examples
<h1>
  <Label variant="subheading" weight="bold">
    Search Results
  </Label>
</h1>

<form>
  <Label variant="label" weight="semibold" htmlFor="email">
    Email Address
  </Label>
  <input id="email" type="email" />
</form>
```

**Use cases:**
- Typography semantics
- Form labels
- Status messages
- Section titles
- Content hierarchy

---

## Premium Component Patterns

### Pattern 1: Card with Badge

```tsx
import { Surface, Badge, Label, Button } from '@/components';

<Surface elevation="raised" rounded="xl" padding="md">
  <div className="flex items-start justify-between mb-4">
    <Label variant="body" weight="semibold">Track Title</Label>
    <Badge variant="default" size="sm">New</Badge>
  </div>
  <Label variant="caption" color="secondary">Artist Name</Label>
  <Button variant="primary" size="sm" className="mt-4 w-full">
    Play Now
  </Button>
</Surface>
```

### Pattern 2: Header with Status

```tsx
import { Surface, Label, Button } from '@/components';

<Surface elevation="floating" background="transparent" padding="lg">
  <div className="flex items-center justify-between">
    <div>
      <Label variant="heading" weight="bold">Page Title</Label>
      <Label variant="caption" color="secondary">Subtitle here</Label>
    </div>
    <Button variant="primary">Action</Button>
  </div>
</Surface>
```

### Pattern 3: Stats Display

```tsx
import { Surface, Label, Badge } from '@/components';
import { Music, TrendingUp } from 'lucide-react';

<div className="grid grid-cols-3 gap-4">
  {[
    { icon: Music, label: 'Tracks', value: 1234, variant: 'default' },
    { icon: TrendingUp, label: 'Plays', value: 5678, variant: 'success' },
  ].map(({ icon: Icon, label, value, variant }) => (
    <Surface key={label} elevation="raised" rounded="lg" padding="md">
      <div className="flex items-start justify-between">
        <div>
          <Label variant="caption" color="muted">{label}</Label>
          <Label variant="2xl" weight="bold">{value.toLocaleString()}</Label>
        </div>
        <div className={`p-2 rounded-lg ${
          variant === 'default' ? 'bg-spotify-green/10 text-spotify-green' :
          'bg-emerald-500/10 text-emerald-400'
        }`}>
          <Icon className="h-5 w-5" />
        </div>
      </div>
    </Surface>
  ))}
</div>
```

---

## Color Palette Reference

### Primary Colors
- `spotify-green` (#1DB954) - Main action color
- `spotify-accent` (#1ed760) - Brighter green for highlights

### Accent Colors
- `spotify-cyan` (#00D9FF) - Blue accent for secondary elements
- `spotify-purple` (#7C3AED) - Purple for future expansion

### Semantic Colors
- `emerald-*` - Success states
- `amber-*` - Warning states
- `red-*` - Error/danger states
- `blue-*` - Info states
- `zinc-*` - Neutral/muted states

---

## Animation Classes

Automatically applied where relevant:

- `animate-fade-in` - Smooth entrance
- `animate-slide-up` - Entrance from bottom
- `animate-pulse-soft` - Gentle breathing effect
- `animate-glow` - Pulsing glow effect

Apply manually:
```tsx
<div className="animate-fade-in">Fades in on mount</div>
<div className="animate-slide-up">Slides up on mount</div>
```

---

## Best Practices

✅ **DO:**
- Use `Surface` for containers
- Use `Label` for typography, not `<p>` or `<span>`
- Use `Button` for all interactive elements
- Use `Badge` for status indicators
- Combine components for complex UIs
- Use semantic `color` prop on Label for meaning

❌ **DON'T:**
- Mix raw HTML text tags with Label components
- Use `<button>` instead of Button component
- Style text directly; use Label variants instead
- Create new elevation styles; use Surface
- Hardcode colors; use component variants

---

## TypeScript Support

All components are fully typed:

```tsx
import { Button, Surface, Badge, Label } from '@/components';
import type { ButtonProps, SurfaceProps, BadgeProps, LabelProps } from '@/components';

const MyButton: React.FC<ButtonProps> = (props) => (
  <Button variant="primary" size="md" {...props} />
);
```

---

## Responsive Design

All components use Tailwind breakpoints:

```tsx
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
  {items.map(item => (
    <Surface key={item.id}>
      {item.name}
    </Surface>
  ))}
</div>
```

---

## Performance Notes

- Components are lightweight, CSS-based
- Animations use GPU-accelerated properties
- No external animation libraries required
- Smooth 60fps animations on modern devices
- Built with Tailwind CSS for minimal bundle impact
