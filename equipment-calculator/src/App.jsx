// Main App Component

import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { EquipmentProvider } from './contexts/EquipmentContext';

// Import page components
import Dashboard from './components/Dashboard/Dashboard';
import AddEquipmentForm from './components/AddEquipment/AddEquipmentForm';

function App() {
  return (
    <EquipmentProvider>
      <Router>
        <div className="App">
          <Routes>
            {/* Dashboard - Equipment Directory */}
            <Route path="/" element={<Dashboard />} />
            
            {/* Add Equipment Form */}
            <Route path="/add" element={<AddEquipmentForm />} />
            
            {/* Equipment Details */}
            <Route path="/equipment/:id" element={<div>Equipment Details - Coming Soon</div>} />
            
            {/* Equipment Edit */}
            <Route path="/equipment/:id/edit" element={<div>Equipment Edit - Coming Soon</div>} />
            
            {/* Catch all - redirect to dashboard */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </div>
      </Router>
    </EquipmentProvider>
  );
}

export default App;