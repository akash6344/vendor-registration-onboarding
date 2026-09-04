export function blankVendor(contact) {
  return {
    id: makeId('vendor'),
    contact,
    onboardingStatus: 'IN_PROGRESS',
    currentStep: 'CATEGORY',
    accountStatus: 'DRAFT',
    mainCategoryId: null,
    vendorType: null,
    subcategoryIds: [],
    serviceIds: [],
    serviceDetails: {},
    personalInfo: {},
    address: {},
    workingHours: { startTime: '09:00', endTime: '18:00', available: true },
    verification: { status: 'PENDING', businessInfo: {}, documents: {} },
    subscription: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

export function dashboard(vendor, db) {
  const category = db.categories.find((item) => item.id === vendor.mainCategoryId);
  const plan = vendor.subscription ? db.plans.find((item) => item.id === vendor.subscription.planId) : null;
  return {
    vendorName: [vendor.personalInfo.firstName, vendor.personalInfo.lastName].filter(Boolean).join(' ') || 'Vendor',
    accountStatus: vendor.accountStatus,
    verificationStatus: vendor.verification.status,
    categoryName: category?.name || null,
    vendorType: vendor.vendorType,
    serviceCount: vendor.serviceIds.length,
    availability: vendor.workingHours.available,
    workingHours: vendor.workingHours,
    plan,
    validUntil: vendor.subscription?.validUntil || null,
    address: vendor.address,
  };
}

export function makeId(prefix) {
  return `${prefix}_${Math.random().toString(36).slice(2, 10)}${Date.now().toString(36)}`;
}
