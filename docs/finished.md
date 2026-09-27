# Assembly complete

Congratulations, you have now assembled your OpenFlexure Microscope.

## The completed microscope {pagestep}

![A render of the completed microscope](renders/complete_microscope_{{var_optics, default:rms}}{{var_body, default:}}0.png)
![A render of the completed microscope](renders/complete_microscope_{{var_optics, default:rms}}{{var_body, default:}}2.png) {{includetext: "
![A render of the completed microscope](renders/complete_microscope_{{var_optics, default:rms}}{{var_body, default:}}3.png)", if: var_body is not _manual}}
![A render of the completed microscope](renders/complete_microscope_{{var_optics, default:rms}}{{var_body, default:}}1.png)
{{includetext: "![A render of the completed microscope](renders/complete_microscope_manual_simple_post.png)", if: var_body is _manual}}


Your completed microscope should now look like these pictures{{includetext: ", with either the full stand or the simple post stand", if: var_body is _manual}}.  
There is also an [interactive 3D view](interactive_3d_view_{{var_optics, default:rms}}{{var_body, default:}}.md) of the finished microscope.

{{includetext: "
## Getting started with your microscope {pagestep}

Using the software on your microscope is detailed on the website, in the ['control' page].  If you access your microscope from another computer it may be helpful to install [OpenFlexure Connect] on your computer to identify your microscope on your local network. 
", if: var_body is not _manual}}

[OpenFlexure Connect]: https://openflexure.org/software/openflexure-connect
['control' page]: https://openflexure.org/projects/microscope/control

## Join the community {pagestep}

OpenFlexure is community project, and we are always delighted to hear from people who have built it on the [OpenFlexure forum](https://openflexure.discourse.group/). The forum is also a great resource for things to do with your microscope, tips and tricks, and others who have built it. Posting photos of your build, pictures taken with the microscope, or even just the fact that you've built it, will all help to keep the project thriving.
