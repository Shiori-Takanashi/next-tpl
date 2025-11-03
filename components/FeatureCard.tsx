interface FeatureCardProps {
  icon: string;
  title: string;
  description: string;
}

export default function FeatureCard({ icon, title, description }: FeatureCardProps) {
  return (
    <div className="group bg-card/98 backdrop-blur-sm border border-border/60 rounded-lg p-6 shadow-sm transition-all duration-300 hover:shadow-md hover:scale-[1.02] hover:bg-card">
      <div className="w-12 h-12 bg-gradient-to-br from-primary/25 to-primary/15 rounded-lg flex items-center justify-center text-2xl mb-4 group-hover:scale-110 transition-transform">
        {icon}
      </div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-muted-foreground text-sm leading-relaxed">{description}</p>
    </div>
  );
}
