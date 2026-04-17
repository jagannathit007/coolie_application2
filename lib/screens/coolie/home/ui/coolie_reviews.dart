import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/api_constants/network_constants.dart';
import 'package:license_sahayak/models/user_model.dart';
import 'package:license_sahayak/repositories/authentication_repo.dart';
import 'package:license_sahayak/utils/app_constants.dart';

class _Review {
  final String id;
  final int rating;
  final String description;
  final String createdAt;
  final String bookingDisplayId;
  final String destination;

  const _Review({required this.id, required this.rating, required this.description, required this.createdAt, required this.bookingDisplayId, required this.destination});

  factory _Review.fromJson(Map<String, dynamic> json) {
    final bookingMap = json['bookingId'] as Map<String, dynamic>? ?? {};
    return _Review(
      id: json['_id']?.toString() ?? '',
      rating: int.tryParse(json['rating'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      bookingDisplayId: bookingMap['bookingId']?.toString() ?? '',
      destination: bookingMap['destination']?.toString() ?? '',
    );
  }
}

enum _RatingFilter { all, fiveStar, fourStar, threeStar, lowStar }

extension _RatingFilterExt on _RatingFilter {
  String get label {
    switch (this) {
      case _RatingFilter.all:
        return 'All';
      case _RatingFilter.fiveStar:
        return '5 ★';
      case _RatingFilter.fourStar:
        return '4 ★';
      case _RatingFilter.threeStar:
        return '3 ★';
      case _RatingFilter.lowStar:
        return '1–2 ★';
    }
  }

  bool matches(int rating) {
    switch (this) {
      case _RatingFilter.all:
        return true;
      case _RatingFilter.fiveStar:
        return rating == 5;
      case _RatingFilter.fourStar:
        return rating == 4;
      case _RatingFilter.threeStar:
        return rating == 3;
      case _RatingFilter.lowStar:
        return rating <= 2;
    }
  }
}

class CoolieReviews extends StatefulWidget {
  final User user;

  const CoolieReviews({super.key, required this.user});

  @override
  State<CoolieReviews> createState() => _CoolieReviewsState();
}

class _CoolieReviewsState extends State<CoolieReviews> {
  final AuthenticationRepo authRepo = AuthenticationRepo();
  final _scrollController = ScrollController();
  final List<_Review> _reviews = [];

  int _page = 1, _totalPages = 1;
  bool _loading = false, _initialLoad = true;
  _RatingFilter _activeFilter = _RatingFilter.all;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loading && _page <= _totalPages) {
        _load();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading || _page > _totalPages) return;
    setState(() => _loading = true);
    try {
      final response = await authRepo.getWorkerReviews(workerId: widget.user.id, page: _page, limit: 10);
      if (response != null) {
        final docs = response['docs'] as List?;
        if (docs != null && docs.isNotEmpty) {
          final reviewDocs = docs.map((e) => _Review.fromJson(e as Map<String, dynamic>)).toList();
          setState(() {
            _reviews.addAll(reviewDocs);
            _totalPages = int.tryParse(response['totalPages'].toString()) ?? 0;
            _page++;
            _initialLoad = false;
          });
        } else {
          setState(() {
            _initialLoad = false;
          });
        }
      } else {
        setState(() {
          _initialLoad = false;
        });
      }
    } catch (e) {
      setState(() {
        _initialLoad = false;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  List<_Review> get _filtered => _reviews.where((r) => _activeFilter.matches(r.rating)).toList();

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return '';
    }
  }

  Widget _starRow(int rating, {double size = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded, size: size, color: i < rating ? const Color(0xFFFBBF24) : const Color(0xFFCBD5E1));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(primary)),
            title: Text(
              "Reviews",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _RatingFilter.values.map((f) {
                    final active = f == _activeFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _activeFilter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? primary : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: active ? primary : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            f.label,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          if (_initialLoad)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: primary)),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index == filtered.length) {
                  return _loading
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator(color: primary, strokeWidth: 2)),
                        )
                      : const SizedBox(height: 80);
                }
                return _buildReviewCard(filtered[index], primary);
              }, childCount: filtered.length + 1),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    final hasImage = widget.user.image != null && widget.user.image!.url.toString().isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primary, primary.withOpacity(0.85)]),
      ),
      padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.network(NetworkConstants.baseUrl + widget.user.image!.url.toString(), fit: BoxFit.cover, errorBuilder: (_, _, _) => _avatarFallback(widget.user.name))
                  : _avatarFallback(widget.user.name),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.user.name.capitalizeFirst ?? widget.user.name,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text("Buckle: ${widget.user.buckleNumber}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    final primary = Constants.instance.primary;
    return Container(
      color: primary.withOpacity(0.7),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'C',
          style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReviewCard(_Review review, Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _ratingColor(review.rating).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: _ratingColor(review.rating)),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: _ratingColor(review.rating)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _starRow(review.rating),
              const Spacer(),
              Text(_formatDate(review.createdAt), style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
            ],
          ),
          if (review.description.isNotEmpty) ...[const SizedBox(height: 10), Text(review.description, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF334155), height: 1.5))],
          if (review.bookingDisplayId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_outlined, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 5),
                  Text(review.bookingDisplayId, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                  if (review.destination.isNotEmpty) ...[
                    Text("  ·  ", style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        review.destination,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _activeFilter == _RatingFilter.all ? "No reviews yet" : "No ${_activeFilter.label} reviews",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 6),
          Text("Reviews will appear here once submitted", style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Color _ratingColor(int rating) {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating == 3) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }
}
