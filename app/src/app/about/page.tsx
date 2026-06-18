import Link from "next/link";

export const metadata = {
  title: "About | Wrought Works",
  description: "Our philosophy, our craft, and our commitment to artisan furniture.",
};

export default function AboutPage() {
  return (
    <div className="flex flex-col min-h-[calc(100vh-5rem)]">
      {/* Hero Section */}
      <section className="relative py-24 md:py-32 overflow-hidden border-b border-glass-border">
        {/* Subtle background glow */}
        <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-primary/5 rounded-full blur-[100px] pointer-events-none" />
        
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
          <h1 className="text-4xl md:text-6xl font-extralight tracking-tight text-white mb-6">
            The <span className="font-semibold text-primary italic">Philosophy</span> of Craft
          </h1>
          <p className="text-xl text-gray-400 leading-relaxed max-w-2xl mx-auto">
            We believe that furniture should not be transient. It should be a permanent fixture in your life, an anchor in your space, and an heirloom for the future.
          </p>
        </div>
      </section>

      {/* Content Section */}
      <section className="py-24 relative z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-16 lg:gap-24 items-center">
            
            <div className="space-y-8">
              <div>
                <h2 className="text-2xl font-light text-white mb-4 uppercase tracking-widest">Our Origins</h2>
                <p className="text-gray-400 leading-relaxed">
                  Wrought Works was born out of a profound frustration with the disposable nature of modern consumer goods. In an era where furniture is designed to last a season, we set out to create pieces designed to last a century.
                </p>
                <p className="text-gray-400 leading-relaxed mt-4">
                  Operating out of our studio in the Pacific Northwest, we combine traditional joinery techniques with modern, brutalist-inspired aesthetics to create statement pieces that demand attention while respecting the natural characteristics of the wood.
                </p>
              </div>
              
              <div>
                <h2 className="text-2xl font-light text-white mb-4 uppercase tracking-widest">The Materials</h2>
                <p className="text-gray-400 leading-relaxed">
                  Every slab of wood has a history. Whether it's a 100-year-old fallen walnut tree or reclaimed oak from an abandoned barn, we source our materials ethically and sustainably. We let the knots, the burls, and the grain dictate the final shape of the piece, rather than forcing the material to conform to a rigid template.
                </p>
              </div>
            </div>
            
            <div className="space-y-8">
              <div className="glass-panel p-8 relative overflow-hidden group">
                <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                <h3 className="text-xl font-medium text-white mb-3">Uncompromising Quality</h3>
                <p className="text-sm text-gray-400 leading-relaxed">
                  We don't use veneers, particle board, or hidden screws. Our joinery is exposed and integral to the design. A Wrought Works piece is solid, heavy, and structurally sound.
                </p>
              </div>
              
              <div className="glass-panel p-8 relative overflow-hidden group">
                <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
                <h3 className="text-xl font-medium text-white mb-3">Small Batch Production</h3>
                <p className="text-sm text-gray-400 leading-relaxed">
                  By intentionally limiting our output, we ensure that every piece receives the meticulous attention it requires. We are artisans, not a factory.
                </p>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-24 border-t border-glass-border bg-black/40">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h2 className="text-3xl font-light text-white mb-6">Ready to find your piece?</h2>
          <div className="flex flex-col sm:flex-row justify-center gap-6 mt-8">
            <Link 
              href="/catalog" 
              className="px-8 py-4 bg-primary text-primary-foreground font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white transition-colors duration-300"
            >
              Browse Catalog
            </Link>
            <Link 
              href="/custom" 
              className="px-8 py-4 glass-panel text-white font-medium tracking-wide uppercase text-sm rounded-sm hover:bg-white/10 transition-colors duration-300"
            >
              Request Custom Work
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
