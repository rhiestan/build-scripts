
// For compilers that support precompilation, includes "wx/wx.h".
#include "wx/wxprec.h"

#ifdef __BORLANDC__
#pragma hdrstop
#endif

#ifndef WX_PRECOMP
#include "wx/wx.h"
#endif

#include "wx/datetime.h"
#include "wx/image.h"
#include "wx/bookctrl.h"
#include "wx/artprov.h"
#include "wx/imaglist.h"
#include "wx/sysopt.h"


#include "wxcmaketestapp.h"



// `Main program' equivalent, creating windows and returning main app frame
bool wxCMakeTestApp::OnInit()
{
#if wxUSE_IMAGE
	wxInitAllImageHandlers();
#endif

/*
	frame->Centre(wxBOTH);

	// Show the frame
	frame->Show(true);

	SetTopWindow(frame);
*/

	return true;
}


IMPLEMENT_APP(wxCMakeTestApp)
