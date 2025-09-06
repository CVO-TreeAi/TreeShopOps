// Stats Overview Component

import React from 'react';
import { useEquipment } from '../../contexts/EquipmentContext';
import { formatCurrency } from '../../utils/calculations';

const StatCard = ({ icon, title, value, subtitle, color = 'accent' }) => {
  const colorClasses = {
    accent: 'text-accent',
    warning: 'text-warning', 
    error: 'text-error',
    blue: 'text-blue-400'
  };

  return (
    <div className="bg-secondary border border-gray-700 rounded-lg p-6 hover:border-gray-600 smooth-transition">
      <div className="flex items-center justify-between">
        <div className="flex-1">
          <div className="flex items-center space-x-3 mb-2">
            <div className={`w-10 h-10 rounded-lg bg-opacity-20 flex items-center justify-center ${
              color === 'accent' ? 'bg-accent' :
              color === 'warning' ? 'bg-warning' :
              color === 'error' ? 'bg-error' :
              'bg-blue-400'
            }`}>
              {icon}
            </div>
            <h3 className="text-sm font-medium text-text-secondary">{title}</h3>
          </div>
          <div className="space-y-1">
            <p className={`text-2xl font-bold ${colorClasses[color]}`}>
              {value}
            </p>
            {subtitle && (
              <p className="text-sm text-text-secondary">{subtitle}</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

const StatsOverview = () => {
  const { getFleetStats } = useEquipment();
  const stats = getFleetStats();

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
      <StatCard
        icon={
          <svg className="w-5 h-5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-6m-2-5h6m-6 0V9a2 2 0 012-2h2a2 2 0 012 2v6.5M7 7h3m0 0h3M7 7v3m3-3v3m0 0h3m-3 0v3" />
          </svg>
        }
        title="Total Equipment"
        value={stats.totalCount.toString()}
        subtitle={`${stats.activeCount} active`}
        color="accent"
      />

      <StatCard
        icon={
          <svg className="w-5 h-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
          </svg>
        }
        title="Fleet Value"
        value={formatCurrency(stats.totalValue, false)}
        subtitle="Total investment"
        color="blue"
      />

      <StatCard
        icon={
          <svg className="w-5 h-5 text-warning" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
          </svg>
        }
        title="Avg. Hourly Cost"
        value={formatCurrency(stats.averageHourlyCost)}
        subtitle="Fleet average"
        color="warning"
      />
    </div>
  );
};

export default StatsOverview;