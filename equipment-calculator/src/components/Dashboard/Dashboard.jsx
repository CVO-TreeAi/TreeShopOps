// Main Dashboard Component

import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useEquipment } from '../../contexts/EquipmentContext';
import { exportEquipmentData } from '../../utils/storage';
import Layout from '../shared/Layout';
import Button from '../shared/Button';
import StatsOverview from './StatsOverview';
import FilterControls from './FilterControls';
import EquipmentGrid from './EquipmentGrid';

const Dashboard = () => {
  const navigate = useNavigate();
  const { equipment } = useEquipment();

  const handleExportData = () => {
    try {
      const exportData = exportEquipmentData();
      
      // Create download link
      const link = document.createElement('a');
      link.href = exportData.dataUri;
      link.download = exportData.filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      
      console.log('Equipment data exported successfully');
    } catch (error) {
      console.error('Failed to export data:', error);
      alert('Failed to export data. Please try again.');
    }
  };

  return (
    <Layout>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Page Header */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-text-primary">Equipment Directory</h1>
            <p className="text-text-secondary mt-1">
              Manage your fleet and track equipment costs
            </p>
          </div>
          
          {/* Action Buttons */}
          <div className="flex items-center space-x-3">
            {equipment.length > 0 && (
              <Button
                variant="outline"
                onClick={handleExportData}
              >
                <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                Export Data
              </Button>
            )}
            
            <Button
              variant="primary"
              onClick={() => navigate('/add')}
            >
              <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
              </svg>
              Add Equipment
            </Button>
          </div>
        </div>

        {/* Stats Overview */}
        <StatsOverview />

        {/* Filter Controls */}
        <FilterControls />

        {/* Equipment Grid */}
        <EquipmentGrid />
      </div>
    </Layout>
  );
};

export default Dashboard;