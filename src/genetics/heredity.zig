const Allele = enum { dominant, recessive };

pub const OrganismType = enum { homozygous_dominant, heterozygous, homozygous_recessive };

pub const Organism = struct {
    alleles: [2]Allele,
    // NOTE: this seems a bit redundant
    type: OrganismType,
};

pub fn getProbabilityOfDominantAlleleInOffspring(left_alleles: [2]Allele, right_alleles: [2]Allele) f64 {
    var dominant_allele_count: f64 = 0.0;

    for (left_alleles) |left_allele| {
        for (right_alleles) |right_allele| {
            if (left_allele == .dominant or right_allele == .dominant) {
                dominant_allele_count += 1;
                continue;
            }
        }
    }

    return dominant_allele_count / 4.0;
}

pub fn organismFromOrganismType(organism_type: OrganismType) Organism {
    return switch (organism_type) {
        .homozygous_dominant => .{ .alleles = .{ .dominant, .dominant }, .type = organism_type },
        .heterozygous => .{ .alleles = .{ .dominant, .recessive }, .type = organism_type },
        .homozygous_recessive => .{ .alleles = .{ .recessive, .recessive }, .type = organism_type },
    };
}
