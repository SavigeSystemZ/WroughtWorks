"use client";

import { useState } from "react";

export default function CustomCommissionPage() {
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    projectType: "",
    details: "",
    budget: ""
  });
  const [status, setStatus] = useState<"idle" | "submitting" | "success" | "error">("idle");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("submitting");
    try {
      const res = await fetch("/api/inquiries", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });
      if (res.ok) {
        setStatus("success");
        setFormData({ firstName: "", lastName: "", email: "", phone: "", projectType: "", details: "", budget: "" });
      } else {
        setStatus("error");
      }
    } catch {
      setStatus("error");
    }
  };
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
      <div className="text-center mb-16">
        <h1 className="text-4xl md:text-5xl font-extralight tracking-tight text-white mb-6">
          Custom <span className="font-semibold text-primary italic">Commissions</span>
        </h1>
        <p className="text-gray-400 text-lg max-w-2xl mx-auto leading-relaxed">
          We collaborate closely with clients to create bespoke furniture that perfectly fits their space and vision. Fill out the form below to begin the dialogue.
        </p>
      </div>

      <div className="glass-panel p-8 md:p-12 rounded-lg relative overflow-hidden">
        {/* Subtle background glow */}
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-primary/10 rounded-full blur-[80px] pointer-events-none" />
        
        <form className="relative z-10 space-y-8" onSubmit={handleSubmit}>
          {status === "success" && (
            <div className="bg-green-500/10 border border-green-500/20 text-green-400 p-4 rounded-sm text-sm text-center">
              Thank you! Your inquiry has been received. We will be in touch soon.
            </div>
          )}
          {status === "error" && (
            <div className="bg-red-500/10 border border-red-500/20 text-red-400 p-4 rounded-sm text-sm text-center">
              An error occurred. Please try again later.
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="space-y-2">
              <label htmlFor="firstName" className="text-xs uppercase tracking-widest text-gray-400">First Name</label>
              <input 
                type="text" 
                id="firstName"
                required
                value={formData.firstName}
                onChange={e => setFormData(f => ({...f, firstName: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="Jane"
              />
            </div>
            <div className="space-y-2">
              <label htmlFor="lastName" className="text-xs uppercase tracking-widest text-gray-400">Last Name</label>
              <input 
                type="text" 
                id="lastName" 
                required
                value={formData.lastName}
                onChange={e => setFormData(f => ({...f, lastName: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="Doe"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div className="space-y-2">
              <label htmlFor="email" className="text-xs uppercase tracking-widest text-gray-400">Email Address</label>
              <input 
                type="email" 
                id="email" 
                required
                value={formData.email}
                onChange={e => setFormData(f => ({...f, email: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="jane@example.com"
              />
            </div>
            <div className="space-y-2">
              <label htmlFor="phone" className="text-xs uppercase tracking-widest text-gray-400">Phone Number (Optional)</label>
              <input 
                type="tel" 
                id="phone" 
                value={formData.phone}
                onChange={e => setFormData(f => ({...f, phone: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
                placeholder="(555) 123-4567"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label htmlFor="projectType" className="text-xs uppercase tracking-widest text-gray-400">Type of Piece</label>
            <select 
              id="projectType" 
              required
              value={formData.projectType}
              onChange={e => setFormData(f => ({...f, projectType: e.target.value}))}
              className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors appearance-none"
            >
              <option value="">Select a category...</option>
              <option value="dining-table">Dining Table</option>
              <option value="coffee-table">Coffee / Side Table</option>
              <option value="seating">Chair / Bench / Seating</option>
              <option value="storage">Console / Cabinet / Storage</option>
              <option value="other">Other / Decor</option>
            </select>
          </div>

          <div className="space-y-2">
            <label htmlFor="details" className="text-xs uppercase tracking-widest text-gray-400">Project Details & Vision</label>
            <textarea 
              id="details" 
              required
              rows={6}
              value={formData.details}
              onChange={e => setFormData(f => ({...f, details: e.target.value}))}
              className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors resize-y"
              placeholder="Tell us about the space, desired dimensions, preferred wood species, or any specific inspiration you have in mind..."
            ></textarea>
          </div>

          <div className="space-y-2">
            <label htmlFor="budget" className="text-xs uppercase tracking-widest text-gray-400">Estimated Budget Range</label>
            <select 
              id="budget" 
              required
              value={formData.budget}
              onChange={e => setFormData(f => ({...f, budget: e.target.value}))}
              className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors appearance-none"
            >
              <option value="">Select a range...</option>
              <option value="1k-3k">$1,000 - $3,000</option>
              <option value="3k-5k">$3,000 - $5,000</option>
              <option value="5k-10k">$5,000 - $10,000</option>
              <option value="10k+">$10,000+</option>
            </select>
          </div>

          <div className="pt-6 border-t border-glass-border">
            <button 
              type="submit" 
              disabled={status === "submitting"}
              className="w-full py-4 bg-primary text-primary-foreground font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white transition-colors duration-300 disabled:opacity-50"
            >
              {status === "submitting" ? "Submitting..." : "Submit Inquiry"}
            </button>
            <p className="mt-4 text-center text-xs text-gray-500">
              We typically respond to new inquiries within 2-3 business days.
            </p>
          </div>
        </form>
      </div>
    </div>
  );
}
