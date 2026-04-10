import React from 'react';

interface SurfaceProps extends React.HTMLAttributes<HTMLDivElement> {
  elevation?: 'flat' | 'raised' | 'elevated' | 'floating';
  background?: 'dark' | 'darker' | 'gradient' | 'transparent';
  rounded?: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | '3xl';
  border?: boolean;
  padding?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
  children: React.ReactNode;
}

const elevationClasses = {
  flat: 'shadow-none',
  raised: 'shadow-card',
  elevated: 'shadow-elevated',
  floating: 'shadow-elevated backdrop-blur-xl',
};

const backgroundClasses = {
  dark: 'bg-[#181818]',
  darker: 'bg-[#0F0F0F]',
  gradient: 'bg-gradient-card',
  transparent: 'bg-black/20 backdrop-blur-md',
};

const roundedClasses = {
  sm: 'rounded-lg',
  md: 'rounded-2xl',
  lg: 'rounded-3xl',
  xl: 'rounded-[32px]',
  '2xl': 'rounded-[40px]',
  '3xl': 'rounded-[48px]',
};

const paddingClasses = {
  xs: 'p-3',
  sm: 'p-4',
  md: 'p-6',
  lg: 'p-8',
  xl: 'p-10',
};

export function Surface({
  elevation = 'raised',
  background = 'dark',
  rounded = 'lg',
  border = true,
  padding = 'md',
  className = '',
  children,
  ...props
}: SurfaceProps) {
  return (
    <div
      className={`
        ${backgroundClasses[background]}
        ${roundedClasses[rounded]}
        ${elevationClasses[elevation]}
        ${paddingClasses[padding]}
        ${border ? 'border border-spotify-border/50' : ''}
        transition-all duration-300 ease-out
        ${className}
      `}
      {...props}
    >
      {children}
    </div>
  );
}
