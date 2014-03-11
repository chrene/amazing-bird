static inline CGFloat abRandf() {
	return rand() / (CGFloat) RAND_MAX;
}
static inline CGFloat abRand(CGFloat low, CGFloat high) {
	return abRandf() * (high - low) + low;
}

static inline NSString *NSStringFromBool(BOOL b)
{
	return b ? @"YES" : @"NO";
}
