// Main Layout Component

import React from 'react';
import { useLocation } from 'react-router-dom';

const Layout = ({ children, title, subtitle, showBackButton = false, onBack }) => {
  const location = useLocation();

  const getPageTitle = () => {
    if (title) return title;
    
    switch (location.pathname) {
      case '/':
        return 'Equipment Directory';
      case '/add':
        return 'Add Equipment';
      default:
        if (location.pathname.startsWith('/equipment/')) {
          return 'Equipment Details';
        }
        return 'Equipment Calculator';
    }
  };

  return (
    <div className="min-h-screen bg-primary">
      {/* Header */}
      <header className="bg-secondary border-b border-gray-700 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              {showBackButton && (
                <button
                  onClick={onBack}
                  className="touch-friendly flex items-center justify-center w-10 h-10 rounded-lg bg-primary hover:bg-gray-600 smooth-transition"
                  aria-label="Go back"
                >
                  <svg className="w-5 h-5 text-text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 19l-7-7 7-7" />
                  </svg>
                </button>
              )}
              <div>
                <h1 className="text-xl font-semibold text-text-primary">
                  {getPageTitle()}
                </h1>
                {subtitle && (
                  <p className="text-sm text-text-secondary">{subtitle}</p>
                )}
              </div>
            </div>
            
            {/* Logo/Brand */}
            <div className="flex items-center">
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-accent rounded-lg flex items-center justify-center">
                  <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2L4 7v10c0 5.55 3.84 9.739 9 10 5.16-.261 9-4.45 9-10V7l-8-5z"/>
                  </svg>
                </div>
                <span className="text-lg font-bold text-text-primary">Equipment Pro</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-secondary border-t border-gray-700 mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <p className="text-sm text-text-secondary">
              © 2025 Equipment Pro. Professional equipment cost management.
            </p>
            <div className="flex items-center space-x-4">
              <span className="text-xs text-text-secondary">v1.0.0</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};

export default Layout;