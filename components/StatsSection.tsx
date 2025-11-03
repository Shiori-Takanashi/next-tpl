import Card, { CardContent } from "./Card";

interface StatItemProps {
  value: string;
  label: string;
}

function StatItem({ value, label }: StatItemProps) {
  return (
    <div className="text-center">
      <div className="mb-1 text-2xl font-bold text-blue-600 md:text-3xl">{value}</div>
      <div className="text-sm text-gray-600">{label}</div>
    </div>
  );
}

export default function StatsSection() {
  const stats = [
    { value: "22.11.0", label: "Node.js" },
    { value: "16.0.0", label: "Next.js" },
    { value: "19.2.0", label: "React" },
    { value: "100%", label: "環境固定" },
  ];

  return (
    <Card>
      <CardContent>
        <div className="grid grid-cols-2 gap-6 md:grid-cols-4">
          {stats.map((stat, index) => (
            <StatItem key={index} value={stat.value} label={stat.label} />
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
