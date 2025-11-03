interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export default function Card({ children, className = "" }: CardProps) {
  return (
    <div
      className={`rounded-lg border border-gray-200 bg-white/95 p-6 shadow-sm backdrop-blur-sm ${className}`}
    >
      {children}
    </div>
  );
}

export function CardHeader({ children, className = "" }: CardProps) {
  return <div className={`mb-4 flex flex-col space-y-1.5 ${className}`}>{children}</div>;
}

export function CardTitle({ children, className = "" }: CardProps) {
  return (
    <h3 className={`text-lg font-semibold leading-none tracking-tight ${className}`}>{children}</h3>
  );
}

export function CardDescription({ children, className = "" }: CardProps) {
  return <p className={`text-sm text-gray-600 ${className}`}>{children}</p>;
}

export function CardContent({ children, className = "" }: CardProps) {
  return <div className={className}>{children}</div>;
}
