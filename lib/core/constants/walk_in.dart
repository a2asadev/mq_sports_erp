/// The walk-in customer of MQ Sports, the first business on the server. It is
/// the same id the server's migration created, and what an app saved before
/// businesses existed still has. Other businesses have their own walk-in
/// customer, which the server names at sign-in (`BusinessInfo.walkInCustomerId`):
/// use `businessProvider`, not this constant, in the app.
const String mqSportsWalkInCustomerId = '00000000-0000-4000-8000-000000000001';
