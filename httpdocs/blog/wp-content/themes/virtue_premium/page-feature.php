<?php
/*
Template Name: Feature
*/
	
	global $post; 
			$headoption = get_post_meta( $post->ID, '_kad_page_head', true ); 
				if ($headoption == 'flex') {
					get_template_part('templates/flex', 'slider');
				}
				else if ($headoption == 'carousel') {
					get_template_part('templates/imagecarousel', 'slider');
				}
				else if ($headoption == 'carouselslider') {
					get_template_part('templates/carousel', 'slider');
				}
				else if ($headoption == 'rev') {
					$above = get_post_meta( $post->ID, '_kad_shortcode_above_header', true ); if(isset($above) && $above != 'on') {
						get_template_part('templates/rev', 'slider');
					}
				}
				else if ($headoption == 'cyclone' || $headoption == 'ktslider') {
					$above = get_post_meta( $post->ID, '_kad_shortcode_above_header', true ); if(isset($above) && $above != 'on') { 
					get_template_part('templates/cyclone', 'slider');
					}
				}
				else if ($headoption == 'video') {
					?>
					 <section class="postfeat pageheadfeature container">
				          <div class="videofit">
				              <?php global $post; $video = get_post_meta( $post->ID, '_kad_post_video', true ); echo do_shortcode($video); ?>
				          </div>
				        </section>
					<?php 
				}
				else if ($headoption == 'image') {
                global $post; $height = get_post_meta( $post->ID, '_kad_posthead_height', true ); if (!empty($height)) $slideheight = $height; else $slideheight = 400; 
                          $swidth = get_post_meta( $post->ID, '_kad_posthead_width', true ); if (!empty($swidth)) $slidewidth = $swidth; else $slidewidth = 1170;   
                          $uselightbox = get_post_meta( $post->ID, '_kad_feature_img_lightbox', true ); if (!empty($uselightbox)) $lightbox = $uselightbox; else $lightbox = 'yes';             
                    $thumb = get_post_thumbnail_id();
                    $img_url = wp_get_attachment_url( $thumb,'full' ); 
                    $image = aq_resize( $img_url, $slidewidth, $slideheight, true ); //resize & crop the image
                    ?>
                    <?php if($image == "") { $image = $img_url; } ?>
                      <div class="container pageheadfeature postfeat feature_container"><div class="imghoverclass img-margin-center">
                      	<?php if($lightbox == 'yes') {?><a href="<?php echo esc_url($img_url); ?>" rel="lightbox" class="lightboxhover"><?php } ?>
                      		<img src="<?php echo esc_url($image) ?>" alt="<?php esc_attr(the_title()); ?>" width="<?php echo esc_attr($slidewidth);?>" height="<?php echo esc_attr($height);?>" />
                      	<?php if($lightbox == 'yes') {?></a><?php } ?>
                      </div></div>
                    <?php
				}
	    /**
    * @hooked virtue_page_title - 20
    */
    do_action('kadence_page_title_container');
    ?>
	
    <div id="content" class="container">
   		<div class="row">
     		<div class="main <?php echo kadence_main_class(); ?>" id="ktmain" role="main">
     			<?php 
                do_action('kadence_page_before_content'); ?>
				<div class="entry-content" itemprop="mainContentOfPage">
					<?php get_template_part('templates/content', 'page'); ?>
					</div>
				<?php 
                /**
                * @hooked virtue_page_comments - 20
                */
                do_action('kadence_page_footer');
                ?>
			</div><!-- /.main -->