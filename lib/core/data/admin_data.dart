import 'package:flutter/material.dart';
import '../models/admin_project.dart';
import '../models/client_request.dart';

class AdminData {
  static List<AdminProject> getMockProjects() {
    return [
      AdminProject(
        name: 'Greenwood Residences',
        location: 'Seattle, WA',
        teamAvatar:
            'https://ui-avatars.com/api/?name=G+R&background=0D8ABC&color=fff',
        status: 'In-Progress',
        statusColor: Colors.blue.shade50,
        statusTextColor: Colors.blue.shade700,
      ),
      AdminProject(
        name: 'Lakeside Office Park',
        location: 'Austin, TX',
        teamAvatar:
            'https://ui-avatars.com/api/?name=L+O&background=FFB300&color=fff',
        status: 'Planning',
        statusColor: Colors.grey.shade100,
        statusTextColor: Colors.grey.shade700,
      ),
      AdminProject(
        name: 'Mountain View Estates',
        location: 'Denver, CO',
        teamAvatar:
            'https://ui-avatars.com/api/?name=M+V&background=4CAF50&color=fff',
        status: 'Completed',
        statusColor: Colors.green.shade50,
        statusTextColor: Colors.green.shade700,
      ),
      AdminProject(
        name: 'Oceanfront Condos',
        location: 'Miami, FL',
        teamAvatar:
            'https://ui-avatars.com/api/?name=O+C&background=F44336&color=fff',
        status: 'Delayed',
        statusColor: Colors.red.shade50,
        statusTextColor: Colors.red.shade700,
      ),
      AdminProject(
        name: 'Riverbend Apartments',
        location: 'Chicago, IL',
        teamAvatar:
            'https://ui-avatars.com/api/?name=R+B&background=673AB7&color=fff',
        status: 'In-Progress',
        statusColor: Colors.blue.shade50,
        statusTextColor: Colors.blue.shade700,
      ),
    ];
  }

  static List<ClientRequest> getMockRequests() {
    return [
      ClientRequest(
        id: '1',
        title: 'Tech Startup Office Renovation',
        clientName: 'Sarah Johnson',
        date: 'July 15, 2024',
        projectType: 'Commercial Renovation',
        description:
            'Modern office space renovation for a tech startup, including open workspaces, meeting rooms, and a break area.',
        imageUrl:
            'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=800',
      ),
      ClientRequest(
        id: '2',
        title: 'Residential Extension in Suburbia',
        clientName: 'Michael Davis',
        date: 'July 12, 2024',
        projectType: 'Residential Extension',
        description:
            'Adding a new bedroom and bathroom to an existing suburban home, with a focus on energy efficiency.',
        imageUrl:
            'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?auto=format&fit=crop&q=80&w=800',
      ),
      ClientRequest(
        id: '3',
        title: 'Retail Store Fit-Out',
        clientName: 'Emily Carter',
        date: 'July 10, 2024',
        projectType: 'Retail Fit-Out',
        description:
            'Complete fit-out for a new clothing store in a shopping mall, including display fixtures, fitting rooms, and point-of-sale area.',
        imageUrl:
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&q=80&w=800',
      ),
      ClientRequest(
        id: '4',
        title: 'Restaurant Renovation in Downtown',
        clientName: 'David Wilson',
        date: 'July 8, 2024',
        projectType: 'Commercial Renovation',
        description:
            'Renovation of an existing restaurant in a downtown area, including kitchen upgrades, dining area redesign, and bar area improvements.',
        imageUrl:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&q=80&w=800',
      ),
    ];
  }
}
