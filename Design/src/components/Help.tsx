import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "./ui/tabs";
import { Input } from "./ui/input";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "./ui/accordion";
import { Separator } from "./ui/separator";
import {
  Search,
  Book,
  MessageCircle,
  Video,
  FileText,
  ExternalLink,
  HelpCircle,
  Users,
  FileSpreadsheet,
  Calculator,
  Settings,
  CreditCard,
  ChevronRight,
  Phone,
  Mail,
  Globe,
  PlayCircle,
  Download,
} from "lucide-react";

interface HelpProps {
  onContactSupport?: () => void;
}

const quickLinks = [
  {
    title: "Getting Started",
    description: "Set up your company and start using Accountanter",
    icon: Settings,
    category: "Setup",
  },
  {
    title: "Creating Invoices",
    description: "Learn how to create and send professional invoices",
    icon: FileText,
    category: "Invoices",
  },
  {
    title: "Managing Clients",
    description: "Add and organize your client information",
    icon: Users,
    category: "Clients",
  },
  {
    title: "Expense Tracking",
    description: "Track and categorize your business expenses",
    icon: Calculator,
    category: "Expenses",
  },
  {
    title: "Financial Reports",
    description: "Generate and analyze financial reports",
    icon: FileSpreadsheet,
    category: "Reports",
  },
  {
    title: "Payment Processing",
    description: "Set up and manage payment methods",
    icon: CreditCard,
    category: "Payments",
  },
];

const faqs = [
  {
    category: "General",
    questions: [
      {
        question: "How do I get started with Accountanter?",
        answer: "To get started, first set up your company information in Settings, then add your clients and create your first invoice. Our getting started guide will walk you through each step."
      },
      {
        question: "Can I import data from other accounting software?",
        answer: "Yes, Accountanter supports importing data from popular accounting software like QuickBooks, as well as CSV files for clients, expenses, and inventory."
      },
      {
        question: "Is my data secure?",
        answer: "Absolutely. We use bank-level encryption to protect your data, and all information is stored securely in the cloud with regular backups."
      },
      {
        question: "Can I use Accountanter on mobile devices?",
        answer: "Yes, Accountanter is fully responsive and works great on tablets and smartphones through your web browser."
      },
    ]
  },
  {
    category: "Invoices",
    questions: [
      {
        question: "How do I customize my invoice template?",
        answer: "Go to Settings > Company to upload your logo and customize your company information. You can also customize invoice fields and add custom terms and conditions."
      },
      {
        question: "Can I set up recurring invoices?",
        answer: "Yes, when creating an invoice, you can set it to automatically recur weekly, monthly, or at custom intervals."
      },
      {
        question: "How do I track invoice payments?",
        answer: "Invoice payments are automatically tracked when you mark them as paid. You can also set up payment reminders for overdue invoices."
      },
      {
        question: "Can I accept online payments?",
        answer: "Yes, you can integrate with payment processors like Stripe or PayPal to accept credit card and ACH payments directly through your invoices."
      },
    ]
  },
  {
    category: "Expenses",
    questions: [
      {
        question: "How do I categorize expenses?",
        answer: "When adding an expense, select from our predefined categories or create custom categories. This helps with tax reporting and business analysis."
      },
      {
        question: "Can I upload receipts?",
        answer: "Yes, you can upload receipt images for each expense. This helps with record keeping and tax compliance."
      },
      {
        question: "How do I approve expense reports?",
        answer: "Team members can submit expenses for approval, and managers can review and approve them in the Expenses section under 'Pending Approval'."
      },
    ]
  },
  {
    category: "Reports",
    questions: [
      {
        question: "What financial reports are available?",
        answer: "Accountanter provides Profit & Loss statements, Cash Flow reports, Invoice Aging reports, and detailed analytics on your business performance."
      },
      {
        question: "Can I export reports?",
        answer: "Yes, all reports can be exported to PDF or CSV format for sharing with accountants or stakeholders."
      },
      {
        question: "How often are reports updated?",
        answer: "Reports are updated in real-time as you add new data. You can view reports for any date range or fiscal period."
      },
    ]
  },
];

const videoTutorials = [
  {
    title: "Getting Started with Accountanter",
    duration: "5:32",
    thumbnail: "tutorial-1",
    description: "Complete setup guide for new users"
  },
  {
    title: "Creating Your First Invoice",
    duration: "3:45",
    thumbnail: "tutorial-2",
    description: "Step-by-step invoice creation tutorial"
  },
  {
    title: "Managing Client Information",
    duration: "4:12",
    thumbnail: "tutorial-3",
    description: "Add and organize your clients effectively"
  },
  {
    title: "Expense Tracking Best Practices",
    duration: "6:18",
    thumbnail: "tutorial-4",
    description: "Efficiently track and categorize expenses"
  },
  {
    title: "Understanding Financial Reports",
    duration: "8:24",
    thumbnail: "tutorial-5",
    description: "Analyze your business performance with reports"
  },
  {
    title: "Setting Up Payment Processing",
    duration: "4:56",
    thumbnail: "tutorial-6",
    description: "Accept payments directly through invoices"
  },
];

export function Help({ onContactSupport }: HelpProps) {
  const [searchTerm, setSearchTerm] = useState("");
  const [activeTab, setActiveTab] = useState("overview");

  const filteredQuickLinks = quickLinks.filter(link =>
    link.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
    link.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const filteredFAQs = faqs.map(category => ({
    ...category,
    questions: category.questions.filter(faq =>
      faq.question.toLowerCase().includes(searchTerm.toLowerCase()) ||
      faq.answer.toLowerCase().includes(searchTerm.toLowerCase())
    )
  })).filter(category => category.questions.length > 0);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1>Help & Support</h1>
          <p className="text-muted-foreground">
            Find answers to common questions and learn how to use Accountanter effectively.
          </p>
        </div>
        <Button onClick={onContactSupport}>
          <MessageCircle className="h-4 w-4 mr-2" />
          Contact Support
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-md mx-auto">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
            <Input
              placeholder="Search help articles..."
              className="pl-10"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </CardContent>
      </Card>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-5">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="guides">User Guides</TabsTrigger>
          <TabsTrigger value="faqs">FAQs</TabsTrigger>
          <TabsTrigger value="videos">Video Tutorials</TabsTrigger>
          <TabsTrigger value="contact">Contact</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-6">
          {/* Quick Links */}
          <Card>
            <CardHeader>
              <CardTitle>Quick Start</CardTitle>
              <CardDescription>
                Get up and running quickly with these essential guides
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {filteredQuickLinks.map((link, index) => (
                  <div key={index} className="p-4 border rounded-lg hover:bg-muted/50 cursor-pointer transition-colors">
                    <div className="flex items-start gap-3">
                      <div className="w-10 h-10 bg-primary/10 rounded-lg flex items-center justify-center">
                        <link.icon className="h-5 w-5 text-primary" />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-medium">{link.title}</h3>
                          <Badge variant="outline" className="text-xs">
                            {link.category}
                          </Badge>
                        </div>
                        <p className="text-sm text-muted-foreground">
                          {link.description}
                        </p>
                        <div className="flex items-center gap-1 mt-2 text-primary text-sm">
                          <span>Learn more</span>
                          <ChevronRight className="h-3 w-3" />
                        </div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Feature Overview */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Book className="h-5 w-5 text-primary" />
                  Documentation
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  Comprehensive guides covering all features of Accountanter.
                </p>
                <Button variant="outline" className="w-full">
                  <FileText className="h-4 w-4 mr-2" />
                  Browse Documentation
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Video className="h-5 w-5 text-primary" />
                  Video Tutorials
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  Watch step-by-step video tutorials for hands-on learning.
                </p>
                <Button variant="outline" className="w-full">
                  <PlayCircle className="h-4 w-4 mr-2" />
                  Watch Tutorials
                </Button>
              </CardContent>
            </Card>
          </div>

          {/* System Status */}
          <Card>
            <CardHeader>
              <CardTitle>System Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-3 h-3 bg-success rounded-full"></div>
                  <div>
                    <p className="font-medium">All Systems Operational</p>
                    <p className="text-sm text-muted-foreground">
                      Last updated: Just now
                    </p>
                  </div>
                </div>
                <Button variant="outline" size="sm">
                  <ExternalLink className="h-4 w-4 mr-2" />
                  Status Page
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="guides" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>User Guides</CardTitle>
              <CardDescription>
                Detailed guides for using all features of Accountanter
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {quickLinks.map((guide, index) => (
                  <div key={index} className="flex items-center justify-between p-4 border rounded-lg">
                    <div className="flex items-center gap-3">
                      <guide.icon className="h-5 w-5 text-primary" />
                      <div>
                        <h3 className="font-medium">{guide.title}</h3>
                        <p className="text-sm text-muted-foreground">
                          {guide.description}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge variant="outline">{guide.category}</Badge>
                      <Button variant="ghost" size="sm">
                        <ChevronRight className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="faqs" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Frequently Asked Questions</CardTitle>
              <CardDescription>
                Find quick answers to common questions
              </CardDescription>
            </CardHeader>
            <CardContent>
              {filteredFAQs.map((category, categoryIndex) => (
                <div key={categoryIndex} className="space-y-4">
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold">{category.category}</h3>
                    <Badge variant="secondary">
                      {category.questions.length} questions
                    </Badge>
                  </div>
                  <Accordion type="single" collapsible className="w-full">
                    {category.questions.map((faq, faqIndex) => (
                      <AccordionItem key={faqIndex} value={`${categoryIndex}-${faqIndex}`}>
                        <AccordionTrigger className="text-left">
                          {faq.question}
                        </AccordionTrigger>
                        <AccordionContent>
                          {faq.answer}
                        </AccordionContent>
                      </AccordionItem>
                    ))}
                  </Accordion>
                  {categoryIndex < filteredFAQs.length - 1 && <Separator />}
                </div>
              ))}
              {filteredFAQs.length === 0 && searchTerm && (
                <div className="text-center py-8 text-muted-foreground">
                  No FAQs found matching "{searchTerm}"
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="videos" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Video Tutorials</CardTitle>
              <CardDescription>
                Learn through comprehensive video guides
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {videoTutorials.map((video, index) => (
                  <div key={index} className="space-y-3">
                    <div className="relative aspect-video bg-muted rounded-lg flex items-center justify-center cursor-pointer hover:bg-muted/80 transition-colors">
                      <PlayCircle className="h-12 w-12 text-primary" />
                      <div className="absolute bottom-2 right-2 bg-black/70 text-white text-xs px-2 py-1 rounded">
                        {video.duration}
                      </div>
                    </div>
                    <div>
                      <h3 className="font-medium">{video.title}</h3>
                      <p className="text-sm text-muted-foreground">
                        {video.description}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="contact" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Contact Support</CardTitle>
                <CardDescription>
                  Get help from our support team
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <div className="flex items-center gap-3">
                    <Mail className="h-5 w-5 text-primary" />
                    <div>
                      <p className="font-medium">Email Support</p>
                      <p className="text-sm text-muted-foreground">
                        support@accountanter.com
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <Phone className="h-5 w-5 text-primary" />
                    <div>
                      <p className="font-medium">Phone Support</p>
                      <p className="text-sm text-muted-foreground">
                        +1 (555) 123-4567
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <MessageCircle className="h-5 w-5 text-primary" />
                    <div>
                      <p className="font-medium">Live Chat</p>
                      <p className="text-sm text-muted-foreground">
                        Available Mon-Fri 9AM-6PM EST
                      </p>
                    </div>
                  </div>
                </div>
                <Button className="w-full" onClick={onContactSupport}>
                  <MessageCircle className="h-4 w-4 mr-2" />
                  Start Live Chat
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Additional Resources</CardTitle>
                <CardDescription>
                  More ways to get help and stay updated
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <Button variant="outline" className="w-full justify-start">
                    <Globe className="h-4 w-4 mr-2" />
                    Community Forum
                    <ExternalLink className="h-4 w-4 ml-auto" />
                  </Button>
                  <Button variant="outline" className="w-full justify-start">
                    <Download className="h-4 w-4 mr-2" />
                    Download User Manual
                  </Button>
                  <Button variant="outline" className="w-full justify-start">
                    <Globe className="h-4 w-4 mr-2" />
                    API Documentation
                    <ExternalLink className="h-4 w-4 ml-auto" />
                  </Button>
                  <Button variant="outline" className="w-full justify-start">
                    <MessageCircle className="h-4 w-4 mr-2" />
                    Feature Requests
                    <ExternalLink className="h-4 w-4 ml-auto" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Support Hours</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h3 className="font-medium mb-3">Standard Support</h3>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span>Monday - Friday</span>
                      <span>9:00 AM - 6:00 PM EST</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Saturday</span>
                      <span>10:00 AM - 2:00 PM EST</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Sunday</span>
                      <span>Closed</span>
                    </div>
                  </div>
                </div>
                <div>
                  <h3 className="font-medium mb-3">Premium Support</h3>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span>24/7 Support</span>
                      <span>Available</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Priority Response</span>
                      <span>&lt; 1 hour</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Phone Support</span>
                      <span>Dedicated Line</span>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}