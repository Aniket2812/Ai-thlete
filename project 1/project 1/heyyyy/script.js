// Dark Mode Toggle Functionality
const darkModeToggle = document.getElementById('darkModeToggle');
if (darkModeToggle) {
    // Check if user has previously set a preference
    const isDarkMode = localStorage.getItem('darkMode') === 'true';
    
    // Apply saved preference on load
    if (isDarkMode) {
        document.body.classList.add('dark-mode');
    }
    
    // Toggle dark mode on button click
    darkModeToggle.addEventListener('click', function() {
        document.body.classList.toggle('dark-mode');
        // Save preference to localStorage
        localStorage.setItem('darkMode', document.body.classList.contains('dark-mode'));
        
        // Update charts if they exist to reflect dark mode changes
        updateChartsForDarkMode();
    });
}

// Function to update charts for dark mode
function updateChartsForDarkMode() {
    const isDarkMode = document.body.classList.contains('dark-mode');
    const gridColor = isDarkMode ? 'rgba(255, 255, 255, 0.1)' : 'rgba(0, 0, 0, 0.05)';
    
    // Update each chart if it exists
    if (typeof streaksChart !== 'undefined') {
        streaksChart.options.scales.y.grid.color = gridColor;
        streaksChart.options.scales.x.grid.color = gridColor;
        streaksChart.update();
    }
    
    if (typeof challengesChart !== 'undefined') {
        challengesChart.update();
    }
    
    if (typeof activityChart !== 'undefined') {
        activityChart.options.scales.y.grid.color = gridColor;
        activityChart.options.scales.x.grid.color = gridColor;
        activityChart.update();
    }
    
    if (typeof performanceChart !== 'undefined') {
        performanceChart.options.scales.y.grid.color = gridColor;
        performanceChart.options.scales.x.grid.color = gridColor;
        performanceChart.update();
    }
}

// Initialize Chart.js
const streaksChart = new Chart(document.getElementById('streaksChart'), {
    type: 'bar',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
            label: 'Streaks',
            data: [12, 19, 3, 5, 8, 10],
            backgroundColor: 'rgba(224, 254, 16, 0.7)',
            borderColor: 'rgba(224, 254, 16, 1)',
            borderWidth: 1,
            borderRadius: 5
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                display: false
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    borderDash: [2, 4],
                    color: 'rgba(0, 0, 0, 0.05)'
                }
            },
            x: {
                grid: {
                    display: false
                }
            }
        }
    }
});

const challengesChart = new Chart(document.getElementById('challengesChart'), {
    type: 'doughnut',
    data: {
        labels: ['Completed', 'In Progress', 'Not Started'],
        datasets: [{
            label: 'Challenges',
            data: [65, 25, 10],
            backgroundColor: [
                'rgba(224, 254, 16, 0.8)',
                'rgba(245, 158, 11, 0.8)',
                'rgba(100, 116, 139, 0.8)'
            ],
            borderWidth: 0,
            cutout: '70%'
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'bottom'
            }
        }
    }
});

// Activity Chart for Dashboard
const activityChart = new Chart(document.getElementById('activityChart'), {
    type: 'line',
    data: {
        labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        datasets: [{
            label: 'Hours',
            data: [3.2, 2.8, 3.5, 2.9, 3.8, 2.5, 2.1],
            borderColor: 'rgba(224, 254, 16, 1)',
            backgroundColor: 'rgba(224, 254, 16, 0.1)',
            tension: 0.4,
            fill: true
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                display: false
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    borderDash: [2, 4],
                    color: 'rgba(0, 0, 0, 0.05)'
                }
            },
            x: {
                grid: {
                    display: false
                }
            }
        }
    }
});

// Performance Chart for Analytics
const performanceChart = new Chart(document.getElementById('performanceChart'), {
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
            label: 'Running',
            data: [65, 72, 78, 75, 82, 88],
            borderColor: 'rgba(224, 254, 16, 1)',
            backgroundColor: 'rgba(224, 254, 16, 0.1)',
            tension: 0.4,
            borderWidth: 2
        },
        {
            label: 'Swimming',
            data: [45, 52, 58, 60, 65, 70],
            borderColor: 'rgba(16, 185, 129, 1)',
            backgroundColor: 'rgba(16, 185, 129, 0.1)',
            tension: 0.4,
            borderWidth: 2
        },
        {
            label: 'Cycling',
            data: [30, 40, 45, 50, 55, 60],
            borderColor: 'rgba(245, 158, 11, 1)',
            backgroundColor: 'rgba(245, 158, 11, 0.1)',
            tension: 0.4,
            borderWidth: 2
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'top'
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    borderDash: [2, 4],
                    color: 'rgba(0, 0, 0, 0.05)'
                }
            },
            x: {
                grid: {
                    display: false
                }
            }
        }
    }
});

// Tab Navigation
const tabs = document.querySelectorAll('.nav-links li');
const contentTabs = document.querySelectorAll('.content-tab');

tabs.forEach(tab => {
    tab.addEventListener('click', () => {
        // Remove active class from all tabs
        tabs.forEach(t => t.classList.remove('active'));
        contentTabs.forEach(ct => ct.classList.remove('active'));

        // Add active class to clicked tab
        tab.classList.add('active');
        const targetTab = document.getElementById(`${tab.dataset.tab}Tab`);
        if (targetTab) {
            targetTab.classList.add('active');
        } else {
            console.error(`Tab with ID ${tab.dataset.tab}Tab not found`);
        }
    });
});

// Search Functionality
document.getElementById('searchInput').addEventListener('input', function(e) {
    const searchTerm = e.target.value.toLowerCase();
    
    // Example search implementation - can be expanded based on needs
    if (searchTerm.length > 2) {
        // Show a visual indicator that search is active
        this.classList.add('searching');
    } else {
        this.classList.remove('searching');
    }
});

// Event Modal
const eventModal = new bootstrap.Modal(document.getElementById('eventModal'));
document.getElementById('addEventBtn').addEventListener('click', () => {
    // Reset form
    document.getElementById('eventForm').reset();
    eventModal.show();
});

document.getElementById('saveEventBtn').addEventListener('click', () => {
    const eventName = document.getElementById('eventName').value;
    const eventDate = document.getElementById('eventDate').value;
    const eventLocation = document.getElementById('eventLocation').value;
    const eventDescription = document.getElementById('eventDescription').value;

    if (!eventName || !eventDate || !eventLocation) {
        alert('Please fill in all required fields');
        return;
    }

    // Format date for display
    const formattedDate = new Date(eventDate).toLocaleDateString('en-US', {
        month: 'short',
        day: 'numeric',
        year: 'numeric'
    });

    // Add event to the grid
    const eventCard = document.createElement('div');
    eventCard.className = 'event-card';
    eventCard.innerHTML = `
        <div class="event-date mb-3 d-inline-block px-3 py-2 bg-primary text-white rounded">
            <i class='bx bx-calendar me-1'></i> ${formattedDate}
        </div>
        <h4>${eventName}</h4>
        <p class="text-muted">${eventLocation}</p>
        <p>${eventDescription}</p>
        <div class="d-flex justify-content-between align-items-center mt-3">
            <span class="badge bg-success">Upcoming</span>
            <div>
                <button class="btn btn-sm btn-outline-primary"><i class='bx bx-edit'></i></button>
                <button class="btn btn-sm btn-outline-danger"><i class='bx bx-trash'></i></button>
            </div>
        </div>
    `;
    document.getElementById('eventsGrid').appendChild(eventCard);

    // Update upcoming events count
    const upcomingEventsElement = document.getElementById('upcomingEvents');
    upcomingEventsElement.textContent = parseInt(upcomingEventsElement.textContent) + 1;

    eventModal.hide();
});

// Add Student Button (placeholder for functionality)
document.getElementById('addStudentBtn').addEventListener('click', () => {
    alert('Add Student functionality to be implemented');
});

// Initialize tooltips
const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
});

// Add event listeners for action buttons in tables
document.querySelectorAll('.btn-outline-primary, .btn-outline-danger').forEach(btn => {
    btn.addEventListener('click', function(e) {
        e.stopPropagation();
        if (this.querySelector('.bx-edit')) {
            alert('Edit functionality to be implemented');
        } else if (this.querySelector('.bx-trash')) {
            if (confirm('Are you sure you want to delete this item?')) {
                // Here you would implement actual delete functionality
                alert('Delete functionality to be implemented');
            }
        }
    });
});

// Notification badge click handler
document.querySelector('.notifications').addEventListener('click', function() {
    alert('You have 3 new notifications');
});

// Settings form handlers
const settingsForms = document.querySelectorAll('#settingsTab .btn-primary');
settingsForms.forEach(btn => {
    btn.addEventListener('click', function() {
        alert('Settings saved successfully!');
    });
});

// Animate stats on page load
window.addEventListener('DOMContentLoaded', () => {
    const statCards = document.querySelectorAll('.stat-card');
    statCards.forEach((card, index) => {
        setTimeout(() => {
            card.classList.add('animate__animated', 'animate__fadeInUp');
        }, index * 100);
    });
});
