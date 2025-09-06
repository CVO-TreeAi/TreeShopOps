// Loading Spinner Component

import React from 'react';

const LoadingSpinner = ({ size = 'md', color = 'accent', text }) => {
  const sizes = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8', 
    lg: 'w-12 h-12',
    xl: 'w-16 h-16'
  };

  const colors = {
    accent: 'text-accent',
    white: 'text-white',
    gray: 'text-gray-400'
  };

  return (
    <div className="flex flex-col items-center justify-center space-y-2">
      <svg
        className={`animate-spin ${sizes[size]} ${colors[color]}`}
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle 
          cx="12" 
          cy="12" 
          r="10" 
          stroke="currentColor" 
          strokeWidth="4" 
          className="opacity-25" 
        />
        <path 
          fill="currentColor" 
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" 
          className="opacity-75" 
        />
      </svg>
      {text && (
        <p className={`text-sm ${colors[color]}`}>{text}</p>
      )}
    </div>
  );
};

export default LoadingSpinner;