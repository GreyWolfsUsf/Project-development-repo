# SAFE Team Online Ride Request Application

A web-based ride request system for students at the University of South Florida (USF) to request nighttime safety rides around campus.

## Project Overview

The SAFE Team app replaces the traditional call-based method of requesting rides with a user-friendly online interface. Students can log in using their USF credentials, request a ride, view estimated wait times, track request status, and receive notifications—all through a secure, accessible web platform.

## Features

- **User Authentication**: Secure login with USF credentials
- **Ride Requests**: Simple interface for requesting rides around campus
- **Wait-Time Estimation**: Real-time updates on expected wait times
- **Request Tracking**: Follow the status of your ride in real-time
- **Notifications**: Receive updates when a driver accepts your ride or arrives
- **Driver Interface**: Drivers can view and manage ride requests
- **Admin Dashboard**: Administrators can manage users, rides, and locations

## Technologies Used

- Ruby 3.2.2
- Rails 7.0.7
- SQLite (development) / PostgreSQL (production)
- Bootstrap 5
- Hotwire (Turbo & Stimulus)
- RSpec for testing

## Getting Started

### Prerequisites

- Ruby 3.2.2 or higher
- Rails 7.0.7 or higher
- SQLite3
- Node.js
- Yarn

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/safe_team_app.git
   cd safe_team_app
   ```

2. Install the dependencies:
   ```bash
   bundle install
   yarn install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. Start the server:
   ```bash
   rails server
   ```

5. Visit `http://localhost:3000` in your browser

### Test Accounts

After running the seed data, you can log in with the following test accounts:

- Student: student1@usf.edu / password
- Driver: driver1@usf.edu / password
- Admin: admin@usf.edu / password

## Development

### Running Tests

```bash
bundle exec rspec
```

### Code Style

This project uses Rubocop for Ruby code style enforcement:

```bash
bundle exec rubocop
```

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

## Project Structure

- `app/models` - Database models and business logic
- `app/controllers` - Request handling and application flow
- `app/views` - UI templates and components
- `app/javascript` - JavaScript/Stimulus controllers
- `app/assets` - Stylesheets, images, and other assets
- `config` - Application configuration
- `db` - Database migrations and seeds
- `spec` - Test files

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b new-feature`
3. Commit your changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin new-feature`
5. Submit a pull request

## Team Members

- Nahid Amirli
- Endrit Ngjelina
- Razim Mammadli
- Kyle Theodore

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- University of South Florida SAFE Team
- USF Student Government
- USF IT Department