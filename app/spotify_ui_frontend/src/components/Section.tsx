import { Label } from './Label';

export function Section({
  title,
  subtitle,
  action,
  children,
}: {
  title: string;
  subtitle?: string;
  action?: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <section className="space-y-6 animate-fade-in">
      <div className="flex items-end justify-between gap-4">
        <div>
          <Label variant="subheading" weight="bold" className="bg-gradient-to-r from-spotify-green to-spotify-cyan bg-clip-text text-transparent">
            {title}
          </Label>
          {subtitle && <Label variant="caption" color="secondary" className="mt-2">{subtitle}</Label>}
        </div>
        {action && <div className="flex-shrink-0">{action}</div>}
      </div>
      <div className="animate-slide-up">{children}</div>
    </section>
  );
}
