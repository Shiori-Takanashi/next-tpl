interface FeatureCardProps {
  icon: string;
  title: string;
  description: string;
}

export default function FeatureCard({ icon, title, description }: FeatureCardProps) {
  return (
    <div className="group bg-white/98 backdrop-blur-sm border border-gray-200 rounded-lg p-6 shadow-sm transition-all duration-300 hover:shadow-md hover:scale-[1.02] hover:bg-white">
      <div className="w-12 h-12 bg-linear-to-br from-blue-100 to-blue-50 rounded-lg flex items-center justify-center text-2xl mb-4 group-hover:scale-110 transition-transform">
        {icon}
      </div>
      <h3 className="text-lg font-semibold mb-2">{title}</h3>
      <p className="text-gray-600 text-sm leading-relaxed">{description}</p>
    </div>
  );
}
