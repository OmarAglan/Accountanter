import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { LucideIcon } from "lucide-react";

interface KPICardProps {
  title: string;
  value: string;
  change?: {
    value: string;
    type: "positive" | "negative" | "neutral";
  };
  icon: LucideIcon;
  trend?: "up" | "down" | "stable";
  borderColor?: "primary" | "accent" | "success" | "warning" | "destructive";
}

export function KPICard({ 
  title, 
  value, 
  change, 
  icon: Icon, 
  trend, 
  borderColor = "primary" 
}: KPICardProps) {
  const getBorderColorClass = () => {
    switch (borderColor) {
      case "primary":
        return "border-t-primary";
      case "accent":
        return "border-t-accent";
      case "success":
        return "border-t-success";
      case "warning":
        return "border-t-warning";
      case "destructive":
        return "border-t-destructive";
      default:
        return "border-t-primary";
    }
  };

  return (
    <Card className={`card-shadow hover:card-shadow-hover transition-all duration-200 border-t-4 ${getBorderColorClass()}`}>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-3">
        <CardTitle className="caption text-muted-foreground">
          {title}
        </CardTitle>
        <div className="bg-muted p-2 rounded-lg">
          <Icon className="h-5 w-5 text-muted-foreground" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          <div className="financial-amount text-2xl font-semibold tracking-tight text-foreground">
            {value}
          </div>
          {change && (
            <div className="flex items-center text-sm">
              <span
                className={`font-medium ${
                  change.type === "positive"
                    ? "text-success"
                    : change.type === "negative"
                    ? "text-destructive"
                    : "text-muted-foreground"
                }`}
              >
                {change.value}
              </span>
              <span className="text-muted-foreground ml-1">from last month</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}