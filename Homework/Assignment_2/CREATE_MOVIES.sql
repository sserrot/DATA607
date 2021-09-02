SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[movies](
	[date_watched] [date] NULL,
	[movie_name] [varchar](255) NULL,
	[imbd_rating] [float] NULL,
	[genre] [varchar](255) NULL,
	[picked_by] [varchar](255) NULL
) ON [PRIMARY]
GO
