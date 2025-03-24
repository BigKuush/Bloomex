foodRescueNFTContract.on("ProductBatchClaimed", async (tokenId, volunteer) => {
    await volunteerRewardsContract.logActivity(volunteer, tokenId, Date.now());
    await qualityRatingContract.recordSuccess(volunteer, 1); // 1 = Volunteer
  });
  