import Card, { CardContent } from './Card';

interface StatItemProps {
  value: string;
  label: string;
}

function StatItem({ value, label }: StatItemProps) {
  return (
    <div className="text-center">
      <div className="text-2xl md:text-3xl font-bold text-blue-600 mb-1">{value}</div>
      <div className="text-sm text-gray-600">{label}</div>
    </div>
  );
}

export default function StatsSection() {
  const stats = [
    { value: "22.11.0", label: "Node.js" },
    { value: "16.0.0", label: "Next.js" },
    { value: "19.2.0", label: "React" },
    { value: "100%", label: "環境固定" }
  ];

  return (
    <Card>
      <CardContent>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {stats.map((stat, index) => (
            <StatItem key={index} value={stat.value} label={stat.label} />
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
