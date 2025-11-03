interface FeatureCardProps {
  icon: string;
  title: string;
  description: string;
}

export default function FeatureCard({ icon, title, description }: FeatureCardProps) {
  return (
    <div className="bg-white/98 group rounded-lg border border-gray-200 p-6 shadow-sm backdrop-blur-sm transition-all duration-300 hover:scale-[1.02] hover:bg-white hover:shadow-md">
      <div className="bg-linear-to-br mb-4 flex h-12 w-12 items-center justify-center rounded-lg from-blue-100 to-blue-50 text-2xl transition-transform group-hover:scale-110">
        {icon}
      </div>
      <h3 className="mb-2 text-lg font-semibold">{title}</h3>
      <p className="text-sm leading-relaxed text-gray-600">{description}</p>
    </div>
  );
}
