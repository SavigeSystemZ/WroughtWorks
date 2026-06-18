"use client";

import { useState } from "react";
import Link from "next/link";

export default function ContactPage() {
  const [formData, setFormData] = useState({ name: "", email: "", message: "" });
  const [status, setStatus] = useState<"idle" | "submitting" | "success" | "error">("idle");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("submitting");
    // In a real app, wire this up to a generic contact route or mailer
    setTimeout(() => {
      setStatus("success");
      setFormData({ name: "", email: "", message: "" });
    }, 1500);
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">
        
        {/* Contact Info */}
        <div className="space-y-12">
          <div>
            <h1 className="text-4xl md:text-5xl font-light text-white tracking-tight mb-6">
              Get in <span className="font-semibold text-primary italic">Touch</span>
            </h1>
            <p className="text-gray-400 leading-relaxed text-lg">
              Whether you have a question about an existing piece, shipping details, or press inquiries, we're here to help.
            </p>
          </div>

          <div className="space-y-8">
            <div>
              <h3 className="text-xs font-bold tracking-widest uppercase text-primary mb-2">Studio Location</h3>
              <p className="text-gray-300">
                Wrought Works Studio<br />
                123 Industrial Ave, Suite 400<br />
                Portland, OR 97204
              </p>
              <p className="text-xs text-gray-500 mt-2 italic">By appointment only.</p>
            </div>
            
            <div>
              <h3 className="text-xs font-bold tracking-widest uppercase text-primary mb-2">General Inquiries</h3>
              <a href="mailto:hello@wroughtworks.com" className="text-gray-300 hover:text-white transition-colors">
                hello@wroughtworks.com
              </a>
            </div>

            <div className="pt-8 border-t border-glass-border">
              <h3 className="text-xl font-light text-white mb-4">Looking for custom work?</h3>
              <p className="text-sm text-gray-400 mb-6">
                If you are looking to commission a custom piece of furniture tailored to your space, please use our dedicated commission form.
              </p>
              <Link 
                href="/custom" 
                className="inline-block px-6 py-3 border border-primary text-primary hover:bg-primary hover:text-primary-foreground text-xs uppercase tracking-widest font-medium rounded-sm transition-colors"
              >
                Go to Commissions &rarr;
              </Link>
            </div>
          </div>
        </div>

        {/* Contact Form */}
        <div className="glass-panel p-8 md:p-10 rounded-lg">
          <h2 className="text-2xl font-light text-white mb-8">Send a Message</h2>
          
          <form className="space-y-6" onSubmit={handleSubmit}>
            {status === "success" && (
              <div className="bg-green-500/10 border border-green-500/20 text-green-400 p-4 rounded-sm text-sm text-center">
                Message sent successfully. We will get back to you shortly.
              </div>
            )}
            
            <div className="space-y-2">
              <label htmlFor="name" className="text-xs uppercase tracking-widest text-gray-400">Name</label>
              <input 
                type="text" 
                id="name"
                required
                value={formData.name}
                onChange={e => setFormData(f => ({...f, name: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
              />
            </div>
            
            <div className="space-y-2">
              <label htmlFor="email" className="text-xs uppercase tracking-widest text-gray-400">Email Address</label>
              <input 
                type="email" 
                id="email"
                required
                value={formData.email}
                onChange={e => setFormData(f => ({...f, email: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors"
              />
            </div>
            
            <div className="space-y-2">
              <label htmlFor="message" className="text-xs uppercase tracking-widest text-gray-400">Message</label>
              <textarea 
                id="message"
                required
                rows={5}
                value={formData.message}
                onChange={e => setFormData(f => ({...f, message: e.target.value}))}
                className="w-full bg-zinc-900/50 border border-glass-border rounded-sm px-4 py-3 text-white focus:outline-none focus:border-primary/50 focus:ring-1 focus:ring-primary/50 transition-colors resize-y"
              ></textarea>
            </div>
            
            <button 
              type="submit" 
              disabled={status === "submitting"}
              className="w-full py-4 bg-white text-black font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-gray-200 transition-colors duration-300 disabled:opacity-50"
            >
              {status === "submitting" ? "Sending..." : "Send Message"}
            </button>
          </form>
        </div>

      </div>
    </div>
  );
}
