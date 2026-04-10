import React from 'react';

interface LabelProps extends React.LabelHTMLAttributes<HTMLLabelElement> {
  variant?: 'heading' | 'subheading' | 'body' | 'caption' | 'label';
  weight?: 'light' | 'normal' | 'medium' | 'semibold' | 'bold';
  color?: 'primary' | 'secondary' | 'muted' | 'success' | 'warning' | 'danger';
  children: React.ReactNode;
}

const variantClasses = {
  heading: 'text-3xl md:text-4xl leading-tight',
  subheading: 'text-xl md:text-2xl leading-relaxed',
  body: 'text-base leading-relaxed',
  caption: 'text-sm leading-relaxed',
  label: 'text-sm font-medium',
};

const weightClasses = {
  light: 'font-light',
  normal: 'font-normal',
  medium: 'font-medium',
  semibold: 'font-semibold',
  bold: 'font-bold',
};

const colorClasses = {
  primary: 'text-white',
  secondary: 'text-zinc-300',
  muted: 'text-zinc-500',
  success: 'text-emerald-400',
  warning: 'text-amber-400',
  danger: 'text-red-400',
};

export function Label({
  variant = 'body',
  weight = 'normal',
  color = 'primary',
  className = '',
  children,
  ...props
}: LabelProps) {
  return (
    <label
      className={`
        ${variantClasses[variant]}
        ${weightClasses[weight]}
        ${colorClasses[color]}
        transition-colors duration-200
        ${className}
      `}
      {...props}
    >
      {children}
    </label>
  );
}
