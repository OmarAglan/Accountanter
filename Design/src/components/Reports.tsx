import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Button } from "./ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "./ui/select";
import { Badge } from "./ui/badge";
import { Progress } from "./ui/progress";
import { KPICard } from "./KPICard";
import {
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from "recharts";
import {
  TrendingUp,
  TrendingDown,
  DollarSign,
  FileText,
  Users,
  Calendar,
  Download,
  Filter,
  Eye,
  Target,
  CreditCard,
  AlertCircle,
} from "lucide-react";

interface ReportsProps {
  onExportReport?: (reportType: string) => void;
}

// Sample data for charts
const monthlyRevenueData = [
  { month: "Jan", revenue: 45000, expenses: 32000, profit: 13000 },
  { month: "Feb", revenue: 52000, expenses: 35000, profit: 17000 },
  { month: "Mar", revenue: 48000, expenses: 38000, profit: 10000 },
  { month: "Apr", revenue: 61000, expenses: 42000, profit: 19000 },
  { month: "May", revenue: 55000, expenses: 40000, profit: 15000 },
  { month: "Jun", revenue: 67000, expenses: 45000, profit: 22000 },
];

const invoiceStatusData = [
  { name: "Paid", value: 65, color: "#27ae60" },
  { name: "Pending", value: 25, color: "#f1c40f" },
  { name: "Overdue", value: 10, color: "#e74c3c" },
];

const cashFlowData = [
  { week: "Week 1", income: 15000, expenses: 12000 },
  { week: "Week 2", income: 18000, expenses: 14000 },
  { week: "Week 3", income: 16000, expenses: 13000 },
  { week: "Week 4", income: 22000, expenses: 16000 },
];

const topClientsData = [
  { name: "Acme Corp", revenue: 45000, invoices: 12 },
  { name: "TechStart Inc", revenue: 38000, invoices: 8 },
  { name: "Design Studio", revenue: 32000, invoices: 15 },
  { name: "Global Solutions", revenue: 28000, invoices: 6 },
  { name: "Innovation Labs", revenue: 25000, invoices: 9 },
];

const expenseCategoryData = [
  { category: "Office Rent", amount: 5000, percentage: 25 },
  { category: "Software", amount: 3000, percentage: 15 },
  { category: "Marketing", amount: 4000, percentage: 20 },
  { category: "Travel", amount: 2000, percentage: 10 },
  { category: "Equipment", amount: 3500, percentage: 17.5 },
  { category: "Other", amount: 2500, percentage: 12.5 },
];

export function Reports({ onExportReport }: ReportsProps) {
  const [selectedPeriod, setSelectedPeriod] = useState("last-6-months");
  const [activeTab, setActiveTab] = useState("overview");

  const handleExportReport = (reportType: string) => {
    onExportReport?.(reportType);
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Financial Reports</h1>
          <p className="text-muted-foreground">
            Analyze your business performance with comprehensive financial insights.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Select value={selectedPeriod} onValueChange={setSelectedPeriod}>
            <SelectTrigger className="w-[180px]">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="last-month">Last Month</SelectItem>
              <SelectItem value="last-3-months">Last 3 Months</SelectItem>
              <SelectItem value="last-6-months">Last 6 Months</SelectItem>
              <SelectItem value="last-year">Last Year</SelectItem>
              <SelectItem value="custom">Custom Range</SelectItem>
            </SelectContent>
          </Select>
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export All
          </Button>
        </div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-6">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="profit-loss">P&L</TabsTrigger>
          <TabsTrigger value="cash-flow">Cash Flow</TabsTrigger>
          <TabsTrigger value="invoices">Invoices</TabsTrigger>
          <TabsTrigger value="clients">Clients</TabsTrigger>
          <TabsTrigger value="expenses">Expenses</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {/* KPI Cards */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <KPICard
              title="Total Revenue"
              value="$328,000"
              change="+12.3%"
              trend="up"
              icon={DollarSign}
              color="success"
            />
            <KPICard
              title="Net Profit"
              value="$96,000"
              change="+8.7%"
              trend="up"
              icon={TrendingUp}
              color="success"
            />
            <KPICard
              title="Outstanding"
              value="$42,500"
              change="-5.2%"
              trend="down"
              icon={FileText}
              color="warning"
            />
            <KPICard
              title="Active Clients"
              value="84"
              change="+15.6%"
              trend="up"
              icon={Users}
              color="info"
            />
          </div>

          {/* Revenue & Profit Chart */}
          <Card>
            <CardHeader>
              <CardTitle>Revenue & Profit Trend</CardTitle>
              <CardDescription>
                Monthly revenue, expenses, and profit over the last 6 months
              </CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={monthlyRevenueData}>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                  <XAxis dataKey="month" className="text-muted-foreground" />
                  <YAxis className="text-muted-foreground" />
                  <Tooltip 
                    contentStyle={{ 
                      backgroundColor: 'var(--color-card)', 
                      border: '1px solid var(--color-border)',
                      borderRadius: 'var(--radius)'
                    }}
                  />
                  <Legend />
                  <Line 
                    type="monotone" 
                    dataKey="revenue" 
                    stroke="var(--color-chart-1)" 
                    strokeWidth={2}
                    name="Revenue"
                  />
                  <Line 
                    type="monotone" 
                    dataKey="expenses" 
                    stroke="var(--color-chart-4)" 
                    strokeWidth={2}
                    name="Expenses"
                  />
                  <Line 
                    type="monotone" 
                    dataKey="profit" 
                    stroke="var(--color-chart-2)" 
                    strokeWidth={2}
                    name="Profit"
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Invoice Status Distribution */}
            <Card>
              <CardHeader>
                <CardTitle>Invoice Status</CardTitle>
                <CardDescription>Current invoice status distribution</CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <PieChart>
                    <Pie
                      data={invoiceStatusData}
                      cx="50%"
                      cy="50%"
                      outerRadius={80}
                      dataKey="value"
                      label={({ name, value }) => `${name}: ${value}%`}
                    >
                      {invoiceStatusData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
                <div className="flex justify-center gap-4 mt-4">
                  {invoiceStatusData.map((item) => (
                    <div key={item.name} className="flex items-center gap-2">
                      <div 
                        className="w-3 h-3 rounded-full" 
                        style={{ backgroundColor: item.color }}
                      />
                      <span className="text-sm">{item.name}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Top Clients */}
            <Card>
              <CardHeader>
                <CardTitle>Top Clients</CardTitle>
                <CardDescription>Highest revenue generating clients</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {topClientsData.map((client, index) => (
                    <div key={client.name} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center text-primary-foreground text-sm font-medium">
                          {index + 1}
                        </div>
                        <div>
                          <p className="font-medium">{client.name}</p>
                          <p className="text-sm text-muted-foreground">
                            {client.invoices} invoices
                          </p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="font-medium financial-amount">
                          ${client.revenue.toLocaleString()}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="profit-loss" className="space-y-6">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Profit & Loss Statement</CardTitle>
                  <CardDescription>Detailed breakdown of revenue and expenses</CardDescription>
                </div>
                <Button variant="outline" onClick={() => handleExportReport('profit-loss')}>
                  <Download className="h-4 w-4 mr-2" />
                  Export P&L
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-6">
                {/* Revenue Section */}
                <div>
                  <h3 className="mb-4 text-success">Revenue</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-2 border-b">
                      <span>Service Revenue</span>
                      <span className="financial-amount">$298,000</span>
                    </div>
                    <div className="flex justify-between items-center py-2 border-b">
                      <span>Product Sales</span>
                      <span className="financial-amount">$30,000</span>
                    </div>
                    <div className="flex justify-between items-center py-2 font-medium">
                      <span>Total Revenue</span>
                      <span className="financial-amount text-success">$328,000</span>
                    </div>
                  </div>
                </div>

                {/* Expenses Section */}
                <div>
                  <h3 className="mb-4 text-destructive">Expenses</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center py-2 border-b">
                      <span>Cost of Goods Sold</span>
                      <span className="financial-amount">$120,000</span>
                    </div>
                    <div className="flex justify-between items-center py-2 border-b">
                      <span>Operating Expenses</span>
                      <span className="financial-amount">$85,000</span>
                    </div>
                    <div className="flex justify-between items-center py-2 border-b">
                      <span>Administrative Expenses</span>
                      <span className="financial-amount">$27,000</span>
                    </div>
                    <div className="flex justify-between items-center py-2 font-medium">
                      <span>Total Expenses</span>
                      <span className="financial-amount text-destructive">$232,000</span>
                    </div>
                  </div>
                </div>

                {/* Net Income */}
                <div className="pt-4 border-t">
                  <div className="flex justify-between items-center py-2 text-lg font-semibold">
                    <span>Net Income</span>
                    <span className="financial-amount text-success">$96,000</span>
                  </div>
                  <div className="flex justify-between items-center py-1 text-sm text-muted-foreground">
                    <span>Profit Margin</span>
                    <span>29.3%</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="cash-flow" className="space-y-6">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Cash Flow Analysis</CardTitle>
                  <CardDescription>Weekly cash inflow and outflow</CardDescription>
                </div>
                <Button variant="outline" onClick={() => handleExportReport('cash-flow')}>
                  <Download className="h-4 w-4 mr-2" />
                  Export Cash Flow
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={400}>
                <AreaChart data={cashFlowData}>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                  <XAxis dataKey="week" className="text-muted-foreground" />
                  <YAxis className="text-muted-foreground" />
                  <Tooltip 
                    contentStyle={{ 
                      backgroundColor: 'var(--color-card)', 
                      border: '1px solid var(--color-border)',
                      borderRadius: 'var(--radius)'
                    }}
                  />
                  <Legend />
                  <Area 
                    type="monotone" 
                    dataKey="income" 
                    stackId="1" 
                    stroke="var(--color-chart-2)" 
                    fill="var(--color-chart-2)"
                    fillOpacity={0.7}
                    name="Income"
                  />
                  <Area 
                    type="monotone" 
                    dataKey="expenses" 
                    stackId="2" 
                    stroke="var(--color-chart-4)" 
                    fill="var(--color-chart-4)"
                    fillOpacity={0.7}
                    name="Expenses"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-success" />
                  Cash Inflow
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-sm">Collections</span>
                    <span className="financial-amount text-success">$65,000</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Other Income</span>
                    <span className="financial-amount text-success">$6,000</span>
                  </div>
                  <div className="flex justify-between font-medium pt-2 border-t">
                    <span>Total Inflow</span>
                    <span className="financial-amount text-success">$71,000</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TrendingDown className="h-5 w-5 text-destructive" />
                  Cash Outflow
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-sm">Operations</span>
                    <span className="financial-amount text-destructive">$45,000</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Investments</span>
                    <span className="financial-amount text-destructive">$10,000</span>
                  </div>
                  <div className="flex justify-between font-medium pt-2 border-t">
                    <span>Total Outflow</span>
                    <span className="financial-amount text-destructive">$55,000</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <DollarSign className="h-5 w-5 text-primary" />
                  Net Cash Flow
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-sm">This Month</span>
                    <span className="financial-amount text-success">+$16,000</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Last Month</span>
                    <span className="financial-amount text-success">+$12,000</span>
                  </div>
                  <div className="flex justify-between font-medium pt-2 border-t">
                    <span>Change</span>
                    <span className="financial-amount text-success">+33.3%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="invoices" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <FileText className="h-5 w-5 text-primary" />
                  Invoice Summary
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Total Invoices</span>
                    <span className="font-medium">127</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Total Value</span>
                    <span className="financial-amount font-medium">$328,450</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Avg. Invoice</span>
                    <span className="financial-amount font-medium">$2,587</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Target className="h-5 w-5 text-success" />
                  Collection Rate
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="text-center">
                    <div className="text-3xl font-bold text-success mb-2">94.2%</div>
                    <p className="text-sm text-muted-foreground">Overall collection rate</p>
                  </div>
                  <Progress value={94.2} className="h-2" />
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Target: 95%</span>
                    <span className="text-success">+2.3% from last month</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <AlertCircle className="h-5 w-5 text-warning" />
                  Payment Metrics
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Avg. Payment Time</span>
                    <span className="font-medium">23 days</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Overdue Amount</span>
                    <span className="financial-amount font-medium text-destructive">$18,750</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Late Payments</span>
                    <span className="font-medium">7.3%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Invoice Aging Report</CardTitle>
              <CardDescription>Outstanding invoices by age</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className="text-center">
                    <div className="text-2xl font-bold text-success">$24,500</div>
                    <p className="text-sm text-muted-foreground">0-30 days</p>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-warning">$12,300</div>
                    <p className="text-sm text-muted-foreground">31-60 days</p>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-destructive">$8,750</div>
                    <p className="text-sm text-muted-foreground">61-90 days</p>
                  </div>
                  <div className="text-center">
                    <div className="text-2xl font-bold text-destructive">$5,200</div>
                    <p className="text-sm text-muted-foreground">90+ days</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="clients" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Top Clients by Revenue</CardTitle>
                <CardDescription>Your most valuable clients this period</CardDescription>
              </CardHeader>
              <CardContent>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={topClientsData}>
                    <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                    <XAxis dataKey="name" className="text-muted-foreground" angle={-45} textAnchor="end" height={80} />
                    <YAxis className="text-muted-foreground" />
                    <Tooltip 
                      contentStyle={{ 
                        backgroundColor: 'var(--color-card)', 
                        border: '1px solid var(--color-border)',
                        borderRadius: 'var(--radius)'
                      }}
                    />
                    <Bar dataKey="revenue" fill="var(--color-chart-1)" />
                  </BarChart>
                </ResponsiveContainer>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Client Performance</CardTitle>
                <CardDescription>Key metrics about your client base</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-6">
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Total Active Clients</span>
                    <span className="font-medium">84</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">New Clients (This Month)</span>
                    <span className="font-medium text-success">+7</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Client Retention Rate</span>
                    <span className="font-medium">96.4%</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Avg. Client Value</span>
                    <span className="financial-amount font-medium">$3,905</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-sm">Repeat Business Rate</span>
                    <span className="font-medium">78.2%</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="expenses" className="space-y-6">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Expense Breakdown</CardTitle>
                  <CardDescription>Analysis of business expenses by category</CardDescription>
                </div>
                <Button variant="outline" onClick={() => handleExportReport('expenses')}>
                  <Download className="h-4 w-4 mr-2" />
                  Export Expenses
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {expenseCategoryData.map((expense) => (
                  <div key={expense.category} className="space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="text-sm font-medium">{expense.category}</span>
                      <div className="flex items-center gap-2">
                        <span className="text-sm text-muted-foreground">
                          {expense.percentage}%
                        </span>
                        <span className="financial-amount font-medium">
                          ${expense.amount.toLocaleString()}
                        </span>
                      </div>
                    </div>
                    <Progress value={expense.percentage} className="h-2" />
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Monthly Expenses</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-center">
                  <div className="text-3xl font-bold text-destructive mb-2">$20,000</div>
                  <p className="text-sm text-muted-foreground">Average monthly spend</p>
                  <div className="mt-4 text-sm">
                    <span className="text-success">-8.2%</span>
                    <span className="text-muted-foreground ml-1">vs last month</span>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Largest Expense</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-center">
                  <div className="text-lg font-bold mb-2">Office Rent</div>
                  <div className="text-2xl font-bold text-destructive mb-2">$5,000</div>
                  <p className="text-sm text-muted-foreground">25% of total expenses</p>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Budget vs Actual</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Budget</span>
                    <span className="financial-amount">$22,000</span>
                  </div>
                  <div className="flex justify-between text-sm">
                    <span>Actual</span>
                    <span className="financial-amount">$20,000</span>
                  </div>
                  <Progress value={90.9} className="h-2" />
                  <div className="text-center text-sm text-success">
                    Under budget by $2,000
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}