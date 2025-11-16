import { KPICard } from "./KPICard";
import { DataTable } from "./DataTable";
import { QuickActions } from "./QuickActions";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import {
  DollarSign,
  Users,
  FileText,
  AlertTriangle,
  TrendingUp,
  Clock,
  CheckCircle,
  XCircle,
} from "lucide-react";

interface DashboardProps {
  onCreateInvoice?: () => void;
  onAddClient?: () => void;
}

export function Dashboard({ onCreateInvoice, onAddClient }: DashboardProps) {
  const kpiData = [
    {
      title: "Total Receivables",
      value: "$47,890",
      change: { value: "+12.5%", type: "positive" as const },
      icon: DollarSign,
      borderColor: "success" as const,
    },
    {
      title: "Total Payables",
      value: "$12,340",
      change: { value: "-8.2%", type: "negative" as const },
      icon: TrendingUp,
      borderColor: "warning" as const,
    },
    {
      title: "Overdue Invoices",
      value: "3",
      change: { value: "+1", type: "negative" as const },
      icon: AlertTriangle,
      borderColor: "destructive" as const,
    },
    {
      title: "Active Projects/Clients",
      value: "47",
      change: { value: "+3", type: "positive" as const },
      icon: Users,
      borderColor: "primary" as const,
    },
  ];

  const recentActivity = [
    {
      id: 1,
      type: "payment",
      description: "Invoice #1024 paid",
      details: "$2,500 from Acme Corp",
      time: "2 hours ago",
      icon: CheckCircle,
      status: "success",
    },
    {
      id: 2,
      type: "client",
      description: "New client 'Tech Solutions' added",
      details: "Contact: hello@techsolutions.com",
      time: "4 hours ago",
      icon: Users,
      status: "info",
    },
    {
      id: 3,
      type: "invoice",
      description: "Invoice #1025 created",
      details: "$1,800 for Design Studio LLC",
      time: "6 hours ago",
      icon: FileText,
      status: "info",
    },
    {
      id: 4,
      type: "overdue",
      description: "Invoice #1020 is overdue",
      details: "$3,200 from Marketing Agency",
      time: "1 day ago",
      icon: XCircle,
      status: "danger",
    },
    {
      id: 5,
      type: "payment",
      description: "Invoice #1023 paid",
      details: "$950 from Global Systems",
      time: "2 days ago",
      icon: CheckCircle,
      status: "success",
    },
  ];

  const getActivityIconColor = (status: string) => {
    switch (status) {
      case "success":
        return "text-success";
      case "danger":
        return "text-destructive";
      case "warning":
        return "text-warning";
      case "info":
      default:
        return "text-primary";
    }
  };

  const getActivityBgColor = (status: string) => {
    switch (status) {
      case "success":
        return "bg-success/10";
      case "danger":
        return "bg-destructive/10";
      case "warning":
        return "bg-warning/10";
      case "info":
      default:
        return "bg-primary/10";
    }
  };

  return (
    <div className="space-y-8">
      {/* Quick Actions */}
      <div>
        <h2 className="mb-4">Quick Actions</h2>
        <QuickActions 
          onCreateInvoice={onCreateInvoice}
          onAddClient={onAddClient}
        />
      </div>

      {/* KPI Cards */}
      <div>
        <h2 className="mb-4">Overview</h2>
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          {kpiData.map((kpi, index) => (
            <KPICard key={index} {...kpi} />
          ))}
        </div>
      </div>

      {/* Recent Activity */}
      <Card className="card-shadow border-t-4 border-t-accent">
        <CardHeader className="pb-4">
          <CardTitle className="flex items-center gap-2">
            <Clock className="h-5 w-5 text-accent" />
            Recent Activity
          </CardTitle>
          <p className="text-sm text-muted-foreground">
            Latest updates and transactions
          </p>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {recentActivity.map((activity) => (
              <div key={activity.id} className="flex items-start space-x-4 pb-4 last:pb-0 border-b border-border last:border-0">
                <div className={`p-2.5 rounded-lg ${getActivityBgColor(activity.status)}`}>
                  <activity.icon className={`h-4 w-4 ${getActivityIconColor(activity.status)}`} />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-foreground">{activity.description}</p>
                  <p className="text-sm text-muted-foreground">{activity.details}</p>
                  <p className="text-xs text-muted-foreground mt-1 flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    {activity.time}
                  </p>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Business Insights */}
      <div className="grid gap-6 lg:grid-cols-2">
        {/* Cash Flow Trend */}
        <Card className="card-shadow border-t-4 border-t-success">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-success" />
              Cash Flow This Month
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-success/5 rounded-lg">
                <div>
                  <p className="text-sm text-muted-foreground">Money In</p>
                  <p className="financial-amount text-xl font-semibold text-success">$35,650</p>
                </div>
                <TrendingUp className="h-8 w-8 text-success" />
              </div>
              <div className="flex items-center justify-between p-4 bg-destructive/5 rounded-lg">
                <div>
                  <p className="text-sm text-muted-foreground">Money Out</p>
                  <p className="financial-amount text-xl font-semibold text-destructive">$12,340</p>
                </div>
                <TrendingUp className="h-8 w-8 text-destructive rotate-180" />
              </div>
              <div className="pt-2 border-t border-border">
                <div className="flex justify-between">
                  <span className="font-medium text-foreground">Net Cash Flow:</span>
                  <span className="financial-amount font-semibold text-success">+$23,310</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Action Items */}
        <Card className="card-shadow border-t-4 border-t-warning">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-warning" />
              Action Required
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center gap-3 p-3 bg-destructive/5 rounded-lg border border-destructive/20">
                <XCircle className="h-6 w-6 text-destructive flex-shrink-0" />
                <div className="min-w-0">
                  <p className="font-medium text-foreground">3 Overdue Invoices</p>
                  <p className="text-sm text-muted-foreground">Total: $7,150 - Follow up required</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 bg-warning/5 rounded-lg border border-warning/20">
                <AlertTriangle className="h-6 w-6 text-warning flex-shrink-0" />
                <div className="min-w-0">
                  <p className="font-medium text-foreground">5 Invoices Due Soon</p>
                  <p className="text-sm text-muted-foreground">Due within 7 days - Send reminders</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 bg-accent/5 rounded-lg border border-accent/20">
                <FileText className="h-6 w-6 text-accent flex-shrink-0" />
                <div className="min-w-0">
                  <p className="font-medium text-foreground">2 Draft Invoices</p>
                  <p className="text-sm text-muted-foreground">Ready to be sent to clients</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}